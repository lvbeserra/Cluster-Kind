#!/bin/bash

# Criação da estrutura de diretórios
mkdir -p values/nginx
mkdir -p values/jenkins
mkdir -p values/harbor
mkdir -p values/sonarqube
mkdir -p values/argocd

# Criação do arquivo values.yaml para NGINX
cat <<EOF > values/nginx/values.yaml
controller:
  service:
    enabled: true
    type: LoadBalancer
EOF

# Criação do arquivo values.yaml para Jenkins
cat <<EOF > values/jenkins/values.yaml
controller:
  service:
    enabled: true
    type: LoadBalancer
EOF

# Criação do arquivo values.yaml para Harbor
cat <<EOF > values/harbor/values.yaml
expose:
  type: ingress
  tls:
    enabled: false

ingress:
  hosts:
    core: harbor.localhost.com

externalURL: http://harbor.localhost.com
EOF

# Criação do arquivo values.yaml para SonarQube
cat <<EOF > values/sonarqube/values.yaml
ingress:
  enabled: true
  hosts:
    - name: sonarqube.localhost.com
EOF

# Criação do arquivo values.yaml para ArgoCD
cat <<EOF > values/argocd/values.yaml
server:
  insecure: true

ingress:
  enabled: true
  hosts:
    - argocd.localhost.com
EOF

echo "Estrutura de diretórios e arquivos 'values.yaml' criada com sucesso!"

