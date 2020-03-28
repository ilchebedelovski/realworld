resource "digitalocean_kubernetes_cluster" "k8s" {
  name    = var.do_cluster_name
  region  = var.do_cluster_region
  version = var.do_cluster_version

  node_pool {
    name       = var.do_cluster_node_pool_name
    size       = var.do_cluster_node_pool_size
    node_count = var.do_cluster_node_pool_node_count
  }
}

provider "kubernetes" {
  load_config_file = false
  host  = digitalocean_kubernetes_cluster.k8s.endpoint
  token = digitalocean_kubernetes_cluster.k8s.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate
  )
}

resource "local_file" "kubeconfig" {
  content = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
  filename = "${path.module}/.kubeconfig"
}

output "cluster-id" {
  value = "${digitalocean_kubernetes_cluster.k8s.id}"
}
