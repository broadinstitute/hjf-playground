
# remote state for this configuration
# each instantiation of a terraform configuration should have its own state file

terraform {
  backend "gcs" {
    bucket = "automatic-potato-hjf-terraform-state"
    prefix = "core"
  }
  required_version = ">= 0.12"
}

