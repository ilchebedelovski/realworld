#!/bin/bash

# Scaling cluster size
# Author: Ilche Bedelovski

cd "$(dirname "$0")"

if [ $# -lt 2 ]; then
  echo "No changes on the cluster, please define number of nodes and node pool size, example NODES=2 SIZE=s-2vcpu-4gb"
  exit 0
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

export TF_VAR_do_cluster_node_pool_node_count=$1
export TF_VAR_do_cluster_node_pool_size=$2

if [[ $TF_VAR_do_cluster_node_pool_node_count -lt "2" ]]; then
  echo -e "\nPlease scale with minimum 2 nodes per cluster, otherwise you will have a downtime during the scheduling process"
  exit 0
fi

echo -e "\n Number of nodes: $TF_VAR_do_cluster_node_pool_node_count"
echo -e "\n Node pool size: $TF_VAR_do_cluster_node_pool_size"

# Terraform init
./bin/terraform init ../terraform
./bin/terraform plan ../terraform

# Terraform apply changes
./bin/terraform apply ../terraform

mv ../terraform/k8s/.kubeconfig .

echo -e "Scaling completed"
