resource "google_compute_global_address" "static_address" {
  provider = google-beta
  name     = format("%s-static", var.site_name)
  labels = {
    app = var.site_name
  }
}
resource "google_compute_managed_ssl_certificate" "cert" {
  provider = google-beta
  name     = "${var.site_name}-cert"
  managed {
    domains = [format("%s.%s.", var.site_name, var.dns_zone)]
  }
}
resource "google_dns_record_set" "dns_set" {
  name         = format("%s.%s.", var.site_name, var.dns_zone)
  type         = "A"
  ttl          = 300
  managed_zone = replace(var.dns_zone, ".", "-")
  rrdatas      = [google_compute_global_address.static_address.address]
}
