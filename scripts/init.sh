#!/bin/bash

# Initializing infrastructure on DigitalOcean
# Author: Ilche Bedelovski

cd "$(dirname "$0")"
mkdir -p bin

# Install kubectl cli
if [[ ! -f bin/kubectl ]]; then
  echo -e "\nInstalling kubectl"
  curl -LO "https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
  chmod +x ./kubectl
  mv kubectl bin/
fi

# Install terraform cli
if [[ ! -f bin/terraform ]]; then
  echo -e "\nInstalling terraform cli"
  curl -o terraform_"$TERRAFORM_VERSION"_linux_amd64.zip https://releases.hashicorp.com/terraform/"$TERRAFORM_VERSION"/terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
  unzip terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
  rm terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
  mv terraform bin
  chmod +x bin/terraform
fi

echo -e "\nBinary clients downloaded"

# Terraform init
./bin/terraform init ../terraform
./bin/terraform plan ../terraform

# Terraform apply changes
./bin/terraform apply ../terraform

mv ../terraform/k8s/.kubeconfig .

echo -e "\nInfrastructure deployed successfully"
