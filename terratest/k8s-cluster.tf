
module "k8s-master" {
  # terraform-shared repo
  source = "github.com/broadinstitute/terraform-shared.git//terraform-modules/k8s-master?ref=hf_k8s_update"
  #  dependencies = [module.enable-services]

  name                     = "${var.appname}-${var.infrastructure_id}"
  location                 = var.k8s_region
  version_prefix           = var.k8s_version_prefix
  network                  = data.terraform_remote_state.base-infrastructure.app-network
  subnetwork               = data.terraform_remote_state.base-infrastructure.app-network-subnets[var.k8s_region]
  authorized_network_cidrs = var.broad_range_cidrs
  #  private_ipv4_cidr_block = var.private_ipv4_cidr_block
}

module "k8s-nodes" {
  # terraform-shared repo
  source = "github.com/broadinstitute/terraform-shared.git//terraform-modules/k8s-node-pool?ref=hf_k8s_update"
  #  dependencies = [module.enable-services,module.k8s-master]
  dependencies = [module.k8s-master]

  name         = "${var.appname}-${var.infrastructure_id}"
  master_name  = module.k8s-master.name
  location     = var.k8s_node_region
  node_count   = var.k8s_node_count
  machine_type = var.k8s_node_machine_type
  disk_size_gb = var.k8s_node_disk_size_gb
  #  labels = var.k8s_node_labels
  #  tags = var.k8s_node_tags
}
