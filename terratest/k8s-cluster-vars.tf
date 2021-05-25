
variable "k8s_version_prefix" {
  type    = string
  default = "1.15"
}

variable "k8s_node_region" {
  type    = string
  default = "us-central1"
}

variable "master_name" {
  type    = string
  default = "eddy"
}

variable "node_name" {
  type    = string
  default = "eddy"
}

variable "node_count" {
  type    = number
  default = "3"
}

variable "machine_type" {
  type    = string
  default = "n1-standard-2"
}

variable "k8s_node_disk_size_gb" {
  type    = number
  default = "50"
}

variable "k8s_node_labels" {
  type    = map(string)
  default = {}
}

variable "k8s_node_tags" {
  type    = list(string)
  default = []
}
