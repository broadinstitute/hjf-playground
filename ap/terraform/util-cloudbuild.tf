
resource "google_cloudbuild_trigger" "util-pr-tests-1" {

  provider = google.automatic-potato-hjf
  name     = "util-pr-tests"
  tags     = ["util-pr-tests-1"]

  github {
    name  = "hjf-playground"
    owner = "broadinstitute"
    pull_request {
      branch          = "main"
      comment_control = "COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"
    }
  }

  included_files = ["util/docker/**"]

  filename = "util/cloudbuild/pr-tests.yaml"
}

resource "google_cloudbuild_trigger" "util-push-any" {

  provider = google.automatic-potato-hjf
  name     = "util-push-any"
  tags     = ["util-push-any"]

  github {
    name  = "hjf-playground"
    owner = "broadinstitute"
    push {
      branch = "[hf_junk|main|develop|staging|prod]"
#      branch = "hf_junk"
    }
  }

  included_files = ["util/docker/**"]

  filename = "util/cloudbuild/docker-build.yaml"
}

resource "google_cloudbuild_trigger" "util-push-main" {

  provider = google.automatic-potato-hjf
  name     = "util-push-main"
  tags     = ["util-push-main"]

  github {
    name  = "hjf-playground"
    owner = "broadinstitute"
    push {
      branch = "main"
    }
  }

  included_files = ["util/docker/**"]

  filename = "util/cloudbuild/release.yaml"
}
