
# remote state for base infrastructure
# by convention all non-prod infrstructures are built in gotc dev

data "terraform_remote_state" "base-infrastructure" {
  backend = "gcs"
  config = {
    bucket = "broad-dsp-terraform-state"
    # NOTE: when base infrastrcuture moves to workspaces the following will change
    path = "gotc/dev"
  }
}

