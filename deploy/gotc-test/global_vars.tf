
variable "broad_range_cidrs" {
  type = list
  default = [
    "69.173.64.0/19",
    "69.173.96.0/20",
    "69.173.112.0/21",
    "69.173.120.0/22",
    "69.173.124.0/23",
    "69.173.126.0/24",
    "69.173.127.0/25",
    "69.173.127.128/26",
    "69.173.127.192/27",
    "69.173.127.224/30",
    "69.173.127.228/32",
    "69.173.127.230/31",
    "69.173.127.232/29",
    "69.173.127.240/28"
  ]
}

variable "broad_routeable_net" {
  type        = string
  default     = "69.173.64.0/18"
  description = "Broad's externally routable IP network"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Default region"
}

#
# NOTE: Until the informaiton belowis exported (as an output) to the base infrastructure
#  need to set it here.  

variable "network_name" {
  type    = string
  default = "app-network"
}

variable "subnetwork_name" {
  type    = string
  default = "app-network"
}
