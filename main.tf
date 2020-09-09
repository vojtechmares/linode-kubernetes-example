module "linode-kubernetes" {
  source       = "./modules/linode-kubernetes"
  linode_token = var.linode_token
  label        = var.label
  tags         = var.tags
  region       = var.region

  k8s_version = var.k8s_version
  node_count  = var.node_count
  node_type   = var.node_type
}

output "prod_kubeconfig" {
  value     = module.linode-kubernetes.linode_lke_cluster.kubeconfig
  sensitive = true
}