#!/bin/bash

# Função para exibir mensagens
function echo_info() {
    echo -e "\n\033[1;32m$1\033[0m"
}

# Atualizar pacotes
echo_info "Atualizando pacotes..."
sudo apt-get update && sudo apt-get upgrade -y

# Instalar o Helm se ainda não estiver instalado
if ! command -v helm &> /dev/null; then
    echo_info "Instalando o Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3.sh | bash
fi

# Adicionando repositórios Helm
echo_info "Adicionando repositórios Helm..."
helm repo add goharbor https://goharbor.github.io/harbor-helm
helm repo add jenkinsci https://charts.jenkins.io
helm repo add argoproj https://argoproj.github.io/argo-helm
helm repo add sonarsource https://SonarSource.github.io/helm-chart-sonarqube

# Atualizando repositórios
echo_info "Atualizando repositórios Helm..."
helm repo update

# Instalação do kubectl
if ! command -v kubectl &> /dev/null; then
    echo_info "Instalando o kubectl..."
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
fi

# Configurando Git
echo_info "Configurando Git..."
git config --global user.email "lvbeserra0@gmail.com"
git config --global user.name "lbeserra"

# Clone seu repositório de projeto
echo_info "Clonando seu repositório de projeto..."
git clone https://github.com/lvbeserra/git_projeto.git
cd git_projeto || exit

# Instalar dependências do seu projeto (exemplo: se for um projeto Node.js)
if [ -f package.json ]; then
    echo_info "Instalando dependências do projeto..."
    npm install
fi

# Configurar e instalar os charts do Helm
echo_info "Instalando charts do Helm..."
kubectl create namespace projeto2 || echo "Namespace projeto2 já existe."

# Verificar se os arquivos de valores existem antes de instalar
for chart in harbor jenkins argo sonarqube; do
    case $chart in
        harbor)
            helm upgrade --install "${chart}-release" goharbor/harbor --namespace projeto2 -f values.yaml
            ;;
        jenkins)
            if [[ -f jenkins-values.yaml ]]; then
                helm upgrade --install "${chart}-release" jenkinsci/jenkins --namespace projeto2 -f jenkins-values.yaml
            else
                echo "Arquivo jenkins-values.yaml não encontrado."
            fi
            ;;
        argo)
            if [[ -f argo-values.yaml ]]; then
                helm upgrade --install "${chart}-release" argoproj/argo --namespace projeto2 -f argo-values.yaml
            else
                echo "Arquivo argo-values.yaml não encontrado."
            fi
            ;;
        sonarqube)
            if [[ -f sonarqube-values.yaml ]]; then
                helm upgrade --install "${chart}-release" sonarsource/sonarqube --namespace projeto2 -f sonarqube-values.yaml
            else
                echo "Arquivo sonarqube-values.yaml não encontrado."
            fi
            ;;
    esac
done
echo_info "Setup concluído!"

