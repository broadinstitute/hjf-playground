output "helm-values" {
  value = templatefile("${path.root}/helm-values.tpl",
    {
      "cert-name"  = module.static_ip.cert.name
      "ip-name"    = module.static_ip.static_ip.name
      "ip-address" = module.static_ip.static_ip.address
    }
  )
}
