
# remote state for this configuration
# each instantiation of a terraform configuration should have its own state file

terraform {
  backend "gcs" {
    bucket = "gotc-engineer-terraform-nonprod-state"
    prefix = "dsde-methods-v39"
  }
  required_version = ">= 0.13"
}

