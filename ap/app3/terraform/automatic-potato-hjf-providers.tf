
# Configure the Google Cloud provider
# Every google project that resources are going ot be created in will have its own 
#  google provider definition using the google project name as its alias so as to be
#  clear

provider "google" {
  alias   = "automatic-potato-hjf"
  project = "automatic-potato-hjf"
  region  = var.region
}

provider "google-beta" {
  alias   = "automatic-potato-hjf"
  project = "automatic-potato-hjf"
  region  = var.region
}

