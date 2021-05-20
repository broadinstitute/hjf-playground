# File controlled by terraform.
# DO NOT modify by hand.

ingress:
  annotations:
    ingress.gcp.kubernetes.io/pre-shared-cert: ${cert-name}
    kubernetes.io/ingress.global-static-ip-name: ${ip-name}
service:
  loadBalancerIP: ${ip-address}
