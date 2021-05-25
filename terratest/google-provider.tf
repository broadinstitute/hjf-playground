
# Configure the Google Cloud provider
provider "google" {
  alias   = "eddy"
  project = var.google_project
  region  = var.region
  version = "~> 3.2"
}

provider "google-beta" {
  alias   = "eddy"
  project = var.google_project
  region  = var.region
  version = "~> 3.2"
}
