
# Configure the Google Cloud provider
# Every google project that resources are going ot be created in will have its own 
#  google provider definition using the google project name as its alias so as to be
#  clear

data "google_project" "automatic-potato-hjf" {
  project_id = "automatic-potato-hjf"
  provider   = google.automatic-potato-hjf
}

