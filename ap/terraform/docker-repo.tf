
resource "google_artifact_registry_repository" "hjf-docker-public" {
  provider = google-beta.automatic-potato-hjf

#  location = "us-central1"
  location = "US"
  repository_id = "hjf-docker-public"
  description = "HJF Docker public repo"
  format = "DOCKER"
}

resource "google_artifact_registry_repository_iam_binding" "hjf-docker-public-reader" {
  provider = google-beta.automatic-potato-hjf
  project = google_artifact_registry_repository.hjf-docker-public.project
  location = google_artifact_registry_repository.hjf-docker-public.location
  repository = google_artifact_registry_repository.hjf-docker-public.name
  role = "roles/artifactregistry.reader"
  members = [
    "allUsers",
  ]
}

resource "google_artifact_registry_repository_iam_binding" "hjf-docker-public-repo-admin" {
  provider = google-beta.automatic-potato-hjf
  project = google_artifact_registry_repository.hjf-docker-public.project
  location = google_artifact_registry_repository.hjf-docker-public.location
  repository = google_artifact_registry_repository.hjf-docker-public.name
  role = "roles/artifactregistry.repoAdmin"
  members = [
    "group:devunll@broadinstitute.org",
    "serviceAccount:${data.google_project.automatic-potato-hjf.number}@cloudbuild.gserviceaccount.com",
  ]
}

resource "google_artifact_registry_repository" "hjf-docker-private" {
  provider = google-beta.automatic-potato-hjf

#  location = "us-central1"
  location = "US"
  repository_id = "hjf-docker-private"
  description = "HJF Docker public repo"
  format = "DOCKER"
}

resource "google_artifact_registry_repository_iam_binding" "hjf-docker-private-reader" {
  provider = google-beta.automatic-potato-hjf
  project = google_artifact_registry_repository.hjf-docker-private.project
  location = google_artifact_registry_repository.hjf-docker-private.location
  repository = google_artifact_registry_repository.hjf-docker-private.name
  role = "roles/artifactregistry.reader"
  members = [
    "domain:broadinstitute.org",
  ]
}

resource "google_artifact_registry_repository_iam_binding" "hjf-docker-private-repo-admin" {
  provider = google-beta.automatic-potato-hjf
  project = google_artifact_registry_repository.hjf-docker-private.project
  location = google_artifact_registry_repository.hjf-docker-private.location
  repository = google_artifact_registry_repository.hjf-docker-private.name
  role = "roles/artifactregistry.repoAdmin"
  members = [
    "group:devunll@broadinstitute.org",
    "serviceAccount:${data.google_project.automatic-potato-hjf.number}@cloudbuild.gserviceaccount.com",
  ]
}
