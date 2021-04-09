
# remote state for this configuration
# each instantiation of a terraform configuration should have its own state file

terraform {
  backend "gcs" {
    bucket = "automatic-potato-hjf-terraform-state"
    prefix = "app3"
  }
  required_version = ">= 0.12"
}

