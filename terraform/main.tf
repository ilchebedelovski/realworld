module "k8s" {
  source = "./k8s"

  do_cluster_name = var.do_cluster_name
  do_cluster_region = var.do_cluster_region
  do_cluster_version = var.do_cluster_version
  do_cluster_node_pool_name = var.do_cluster_node_pool_name
  do_cluster_node_pool_size = var.do_cluster_node_pool_size
  do_cluster_node_pool_node_count = var.do_cluster_node_pool_node_count
}

module "space" {
  source = "./space"

  do_bucket_name = var.do_bucket_name
  do_bucket_region = var.do_bucket_region
}
