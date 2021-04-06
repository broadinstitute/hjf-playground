
# secret for github personal access token

resource "google_secret_manager_secret" "hjfbynara-github-pat" {
  provider = google.automatic-potato-hjf

  secret_id = "hjfbynara-github-pat"

  labels = {
    project = "automatic-potato-hjf"
  }

  replication {
    automatic = true
  }
}

# IAM access for secret

resource "google_secret_manager_secret_iam_member" "hjfbynara-github-pat-read" {
  provider  = google.automatic-potato-hjf
  secret_id = google_secret_manager_secret.hjfbynara-github-pat.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.automatic-potato-hjf.number}@cloudbuild.gserviceaccount.com"
}

