output "cert" {
  description = "google_compute_managed_ssl_certificate resource"
  value       = google_compute_managed_ssl_certificate.cert
}
output "static_ip" {
  description = "google_compute_global_address resource"
  value       = google_compute_global_address.static_address
}
