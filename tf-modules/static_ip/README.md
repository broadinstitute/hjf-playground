## Static IP Address Terraform Module

Deploys a static IP, sets dns record, and automatically manages certs.

### Variables
```
dns_zone        - zone for dns record set and ssl cert
site_name       - name of the site being deployed
```

### Outputs

The module will output the different resources that are created so they can be referenced.

```
cert           - google_compute_managed_ssl_certificate resource
static_ip      - google_compute_global_address resource
```

### Usage

The following will
1. Create a static IP address
2. Set a dns record for `example-site.example.com` pointing at that address
3. Setup managed ssl certs for that site
4. Output the static ip address that was created

```
provider "google" {
  project = "my-project-id"
  region  = "us-central1"
}
provider "google-beta" {
  project = "my-project-id"
  region  = "us-central1"
}
module "example_site_static" {
  source    = "./static_ip"
  dns_zone  = "example.com"
  site_name = "example-site"
}
output "static_ip_address" {
  description = "static ip address created by the module"
  value       = module.example_site_static.static_ip.address
}
```
