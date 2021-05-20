
module "ap-nginx" {
  # terraform-shared repo
  source = "github.com/broadinstitute/hjf-playground.git//tf-modules/ap-nginx?ref=tf-ap-nginx-1.2"

  providers = {
    google      = google.ap-env
    google-beta = google-beta.ap-env
  }

  dns_zone    = var.ap-app-zone
  ap-app-name = var.ap-app-name
}
