
module "cloud-nat" {
  source = "github.com/broadinstitute/gotc-deploy.git//terraform/cloud_nat?ref=tf_cloud-nat-0.0.1"

  providers = {
    google      = google.broad-gotc-dev
    google-beta = google-beta.broad-gotc-dev
  }
  cloud_nat_name    = "cloud-nat-${var.network_name}-${var.region}"
  cloud_nat_region  = var.region
  cloud_nat_num_ips = "1"
  cloud_nat_labels = {
    "role"    = "cloud-nat",
    "network" = var.network_name,
    "region"  = var.region
  }
  cloud_nat_network    = data.terraform_remote_state.base-infrastructure.outputs.app-network
  cloud_nat_subnetwork = data.terraform_remote_state.base-infrastructure.outputs.app-network-subnets[var.region]
}

