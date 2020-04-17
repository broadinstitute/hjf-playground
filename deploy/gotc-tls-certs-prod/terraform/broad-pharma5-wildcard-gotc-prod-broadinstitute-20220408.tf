
module "broad-pharma5-20220408" {
  source = "github.com/broadinstitute/gotc-deploy.git//terraform/ssl_cert?ref=tf_ssl_cert-0.0.1"

  providers = {
    google = google.broad-pharma5
  }
  ssl_certificate_name = "wildcard-gotc-prod-broadinstitute-20220408"
  ssl_certificate_key  = file("wildcard-gotc-prod-broadinstitute-ssl-certificate-20220408.key")
  ssl_certificate_cert = file("wildcard-gotc-prod-broadinstitute-ssl-certificate-20220408.crt")

}

