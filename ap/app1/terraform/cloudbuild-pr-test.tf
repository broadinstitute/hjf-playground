
resource "google_cloudbuild_trigger" "app1-terraform-pr-test" {

  provider = google.automatic-potato-hjf
  name     = "app1-terraform-pr-test"
  tags     = ["app1-terraform-pr-test"]

  github {
    name  = "hjf-playground"
    owner = "broadinstitute"
    pull_request {
      branch          = "main"
      comment_control = "COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"
    }
  }

  included_files = ["ap/app1/terraform/**"]

  excluded_files = ["ap/app1/terraform/cloudbuild-pr-test.yaml", "ap/app1/terraform/.gitignore"]

  filename = "ap/app1/terraform/cloudbuild-pr-test.yaml"
}

