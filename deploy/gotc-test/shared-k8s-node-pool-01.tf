
module "shared-k8s-node-pool-100" {
  # terraform-shared repo
  source       = "github.com/broadinstitute/terraform-shared.git//terraform-modules/k8s-node-pool?ref=k8s-node-pool-0.1.0-tf-0.12"
  dependencies = [module.shared-k8s-master]

  providers = {
    google      = google.broad-gotc-dev
    google-beta = google-beta.broad-gotc-dev
  }
  name         = "${var.shared_k8s_name}-${var.shared_k8s_node_pool_01_location}-01"
  master_name  = module.shared-k8s-master.name
  location     = var.shared_k8s_node_pool_01_location
  node_count   = var.shared_k8s_node_pool_01_count
  machine_type = var.shared_k8s_node_pool_01_machine_type
  disk_size_gb = var.shared_k8s_node_pool_01_disk_size_gb
  labels       = var.shared_k8s_node_pool_01_labels
}
