output "helm-values" {
  value = templatefile("${module.root}/helm-values.tpl",
    {
      "cert-name"  = module.static-ip.cert.name
      "ip-name"    = module.static-ip.static_ip.name
      "ip-address" = module.static-ip.static_ip.address
    }
  )
}
