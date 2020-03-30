
variable "shared_k8s_version_prefix" {
  type    = string
  default = "1.15"
}

variable "shared_k8s_providers" {
  type    = map
  default = {}
}

variable "shared_k8s_region" {
  type    = string
  default = "us-central1"
}

variable "shared_k8s_location" {
  type    = string
  default = "us-central1-a"
}

variable "shared_k8s_private_ipv4_cidr_block" {
  type    = string
  default = "10.127.0.0/28"
}

variable "shared_k8s_name" {
  type    = string
  default = "gotc-dev-shared"
}

variable "shared_k8s_node_pool_01_location" {
  type    = string
  default = "us-central1-a"
}

variable "shared_k8s_node_pool_01_count" {
  type    = number
  default = "3"
}

variable "shared_k8s_node_pool_01_machine_type" {
  type    = string
  default = "n1-standard-2"
}

variable "shared_k8s_node_pool_01_disk_size_gb" {
  type    = number
  default = "50"
}

variable "shared_k8s_node_pool_01_labels" {
  type = map(string)
  default = {
    pool = "01"
  }
}

variable "nshared_k8s_node_pool_01_tags" {
  type    = list(string)
  default = []
}
