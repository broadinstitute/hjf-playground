module "static-ip" {
  # terraform-shared repo
  source = "github.com/broadinstitute/hjf-playground.git//tf-modules/static_ip?ref=tf-static_ip-1.0"

  providers = {
    google      = google
    google-beta = google-beta
  }

  dns_zone  = var.dns_zone
  site_name = var.ap-app-name
}

