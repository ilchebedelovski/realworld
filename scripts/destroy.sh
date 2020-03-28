#!/bin/bash

# Initializing infrastructure on DigitalOcean
# Author: Ilche Bedelovski

cd "$(dirname "$0")"

# Install terraform cli
if [[ ! -f bin/terraform ]]; then
  mkdir -p bin
  echo -e "\nInstalling terraform cli"
  curl -o terraform_"$TERRAFORM_VERSION"_linux_amd64.zip https://releases.hashicorp.com/terraform/"$TERRAFORM_VERSION"/terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
  unzip terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
  rm terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
  mv terraform bin
  chmod +x bin/terraform
fi

echo -e "Destroying the cluster"

# Terraform destroy
./bin/terraform destroy ../terraform

# Removing the initialized Terraform data
rm -Rvf terraform.tfstate*
rm -Rvf .terraform/
rm .kubeconfig
