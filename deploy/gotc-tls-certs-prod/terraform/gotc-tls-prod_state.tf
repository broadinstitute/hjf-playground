
# remote state for this configuration
# each instantiation of a terraform configuration should have its own state file

terraform {
  backend "gcs" {
    bucket = "gotc-engineer-terraform-prod-state"
    prefix = "gotc-tls-prod"
  }
  required_version = ">= 0.12"
}

