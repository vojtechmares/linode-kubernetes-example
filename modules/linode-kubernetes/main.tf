resource "linode_lke_cluster" "prod" {
  label  = var.label
  tags   = var.tags
  region = var.region

  k8s_version = var.k8s_version

  pool {
    count = var.node_count

    type = var.node_type
  }
}

data "linodex_instance_ips" "prod_nodes" {
  count = var.node_count

  id = linode_lke_cluster.prod.pool[0].nodes[count.index].instance_id
}

resource "linode_nodebalancer" "prod" {
  label  = var.label
  tags   = var.tags
  region = var.region

  client_conn_throttle = 20
}

resource "linode_nodebalancer_config" "prod80" {
  nodebalancer_id = linode_nodebalancer.prod.id
  protocol        = "tcp"
  port            = 80

  check          = "connection"
  check_attempts = 3
  check_timeout  = 3
  check_interval = 10
}

resource "linode_nodebalancer_config" "prod443" {
  nodebalancer_id = linode_nodebalancer.prod.id
  protocol        = "tcp"
  port            = 443

  check          = "connection"
  check_attempts = 3
  check_timeout  = 3
  check_interval = 10
}

resource "linode_nodebalancer_node" "prod80" {
  count = var.node_count

  label = "${var.label}-80-${count.index}"

  nodebalancer_id = linode_nodebalancer.prod.id
  config_id       = linode_nodebalancer_config.prod80.id

  address = "${data.linodex_instance_ips.prod_nodes[count.index].private[0]}:30001"
  weight  = 1
}

resource "linode_nodebalancer_node" "prod443" {
  count = var.node_count

  label = "${var.label}-443-${count.index}"

  nodebalancer_id = linode_nodebalancer.prod.id
  config_id       = linode_nodebalancer_config.prod443.id

  address = "${data.linodex_instance_ips.prod_nodes[count.index].private[0]}:30002"
  weight  = 1
}

output "linode_lke_cluster" {
  value = linode_lke_cluster.prod
}

// output "prod_kubeconfig" {
//   value = module.k8s-prod.linode_lke_cluster.kubeconfig
//   sensitive = true
// }

output "linode_nodebalancer" {
  value = linode_nodebalancer.prod
}