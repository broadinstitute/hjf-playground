
module "gotc-cromwell" {
  source = "github.com/broadinstitute/gotc-deploy.git//terraform/firewall_rule?ref=tf_firewall_rule-0.0.1"

  providers = {
    google      = google.broad-gotc-dev
    google-beta = google-beta.broad-gotc-dev
  }
  firewall_rule_name          = "${var.network_name}-gotc-cromwell-permit"
  firewall_rule_network       = data.terraform_remote_state.base-infrastructure.outputs.app-network
  firewall_rule_source_ranges = module.cloud-nat.cloud_nat_ips
  firewall_rule_ports         = ["80", "443"]
  firewall_rule_target_tags   = ["cromwell"]
  firewall_rule_logging       = true

}

