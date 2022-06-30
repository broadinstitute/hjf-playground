variable "test_project_id" {
  default = "automatic-potato-develop"
}

# Trigger to build images inside the containers folder upon changes
module "terraform-trigger" {
  source      = "git::https://github.com/broadinstitute/bits-ap-modules.git//tf-modules/cloudbuild_trigger?ref=main"
  description = "Terraform plan/apply"

  trigger_name = "terraform-plan-apply"

  github_repo = "hjf-playground"
  filename    = "ap/terraform/cloudbuild.yaml"
  #  setting it to a non-existent branch since there is no way to create a trigger via TF
  #  that is only manually triggered 
  branch_name = "NO_SUCH_BRANCH"
  substitutions = {
    "_TF_LOG"   = "",
    "_TARGETS"  = "",
    "_ENV"      = var.test_project_id == "automatic-potato-production"? "production" : var.test_project_id == "automatic-potato-staging" ? "staging" : var.test_project_id == "automatic-potato-develop" ? "develop": "",
    "_TF_APPLY" = "no",
  }
}
