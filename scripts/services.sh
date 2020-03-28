#!/bin/bash

# Script for deploying cluster services
# Author: Ilche Bedelovski

cd "$(dirname "$0")"

# Install kubectl cli
if [[ ! -f bin/kubectl ]]; then
  echo -e "\nInstalling kubectl"
  curl -LO "https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
  chmod +x ./kubectl
  mv kubectl bin/
fi

# Install helm cli
if [[ ! -f bin/helm ]]; then
  echo -e "\nInstalling helm cli"
  curl -o "$HELM_VERSION-linux-amd64.tar.gz" "https://get.helm.sh/$HELM_VERSION-linux-amd64.tar.gz"
  tar zxf "$HELM_VERSION-linux-amd64.tar.gz"
  mv linux-amd64/helm bin
  chmod +x bin/helm
  rm -Rvf linux-amd64
  rm helm-v3.1.1-linux-amd64.tar.gz
fi

# Install NGINX Ingress Controller
echo -e "\nInstalling NGINX Ingress Controller"
./bin/kubectl --kubeconfig .kubeconfig apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/$NGINX_VERSION/deploy/static/mandatory.yaml
./bin/kubectl --kubeconfig .kubeconfig apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/$NGINX_VERSION/deploy/static/provider/cloud-generic.yaml

# Creating namespaces since Helm 3 cannot create namespaces when installing application on Kubernetes
echo -e "\nCreating app namespaces"
./bin/kubectl --kubeconfig .kubeconfig create namespace $APP_PROD_NAME
./bin/kubectl --kubeconfig .kubeconfig create namespace $APP_STAGE_NAME

# Check if the .s3cfg file exists
if [ ! -f ../.s3cfg ]; then
  echo "Please make a copy from .s3cfg.sample to .s3cfg and place the required secret values"
  exit 0
fi

# Deploying the backup manifests
echo -e "\nDeploying the backup manifests"
./bin/kubectl --kubeconfig .kubeconfig --namespace $APP_PROD_NAME create configmap backup --from-file ../.s3cfg
./bin/kubectl --kubeconfig .kubeconfig --namespace $APP_PROD_NAME apply -f ../k8s/backup/backup-secret.yaml
./bin/kubectl --kubeconfig .kubeconfig --namespace $APP_PROD_NAME apply -f ../k8s/backup/backup-pvc.yaml
./bin/kubectl --kubeconfig .kubeconfig --namespace $APP_PROD_NAME apply -f ../k8s/backup/backup-cronjob.yaml

# Deploying Timberio for collecting logs on the cluster
echo -e "\nDeploying the Timberio log collector"
./bin/kubectl --kubeconfig .kubeconfig create namespace $LOGGING_NS
./bin/kubectl --kubeconfig .kubeconfig create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-service-account.yaml
./bin/kubectl --kubeconfig .kubeconfig create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-role.yaml
./bin/kubectl --kubeconfig .kubeconfig create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-role-binding.yaml
./bin/kubectl --kubeconfig .kubeconfig create -f https://gist.githubusercontent.com/binarylogic/951ea32ed462933fa70c439f9cab06f3/raw/fe6b761770f1ccd9b44c96421d4892b8e96927d6/fluent-bit-configmap.yaml
./bin/kubectl --kubeconfig .kubeconfig --namespace $LOGGING_NS create secret generic timber --from-literal="fluent_timber_api_key=$LOGGING_TIMBER_KEY" --from-literal="fluent_timber_source_id=$LOGGING_TIMBER_SOURCE_ID"
./bin/kubectl --kubeconfig .kubeconfig create -f../k8s/fluentd/fluent-bit-ds.yaml

# Deploying Prometheus and Grafana
./bin/helm --kubeconfig .kubeconfig upgrade --install $MONITORING_NS stable/prometheus-operator --version=$MONITORING_VERSION --namespace=$MONITORING_NS --set grafana.ingress.enabled=true --set grafana.ingress.hosts[0]=$MONITORING_HOST
