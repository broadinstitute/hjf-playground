
data "google_dns_managed_zone" "dsde-methods" {
  name    = "methods-dev"
  project = "broad-dsde-methods"
}
