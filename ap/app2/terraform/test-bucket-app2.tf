module "automatic-potato-hjf-app2-bucket" {
  # terraform-shared repo
  source = "github.com/broadinstitute/terraform-shared.git//terraform-modules/storage-bucket?ref=storage-bucket-0.0.4"

  providers = {
    google = google.automatic-potato-hjf
  }

  # Create one bucket and set ACLs
  bucket_name = "automatic-potato-hjf-app2"
  versioning  = false
  lifecycle_rules = [
    {
      # delete after 14 days
      action = {
        type = "Delete"
      },
      condition = {
        age        = 14
        with_state = "ANY"
      }
  }]

  bindings = {
    storage_admins = {
      role = "roles/storage.admin"
      members = [
        "group:devnull@broadinstitute.org",
      ]
    },
    admins = {
      role = "roles/storage.objectAdmin"
      members = [
        "serviceAccount:${data.google_project.automatic-potato-hjf.number}@cloudbuild.gserviceaccount.com",
      ]
    }
  }
}
