
# SA secret for each env/potato project.  secret should begin with google project name

resource "google_secret_manager_secret" "automatic-potato-hjf-ap-service-account" {
  provider  = 

  secret_id = "automatic-potato-hjf-ap-service-account"

  labels = {
    project = "automatic-potato-hjf"
  }

  replication {
    automatic = true
  }
}

# IAM access for secret

resource "google_secret_manager_secret_iam_member" "member" {
  provider = 
#  project = google_secret_manager_secret.secret-basic.project
  secret_id = google_secret_manager_secret.automatic-potato-hjf-ap-service-account.automatic-potato-hjf-ap-service-account
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${data.google_project.automatic-potato-hjf.number}@cloudbuild.gserviceaccount.com"
}

