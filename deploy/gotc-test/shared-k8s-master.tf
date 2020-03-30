
module "shared-k8s-master" {
  # terraform-shared repo
  source = "github.com/broadinstitute/terraform-shared.git//terraform-modules/k8s-master?ref=k8s-master-0.1.1-tf-0.12"

  providers = {
    google      = google.broad-gotc-dev
    google-beta = google-beta.broad-gotc-dev
  }
  name                     = "${var.shared_k8s_name}-${var.shared_k8s_location}"
  location                 = var.shared_k8s_location
  version_prefix           = var.shared_k8s_version_prefix
  network                  = data.terraform_remote_state.base-infrastructure.outputs.app-network
  subnetwork               = data.terraform_remote_state.base-infrastructure.outputs.app-network-subnets[var.shared_k8s_region]
  authorized_network_cidrs = var.broad_range_cidrs
  private_ipv4_cidr_block  = var.shared_k8s_private_ipv4_cidr_block
}

