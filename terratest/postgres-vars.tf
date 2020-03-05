variable "postgres_tier" {
  default     = "db-n1-standard-1"
  description = "The default instance size "
}

variable "postgres_num_instances" {
  default     = "0"
  description = "number of cromwell 500 database instances"
}

variable "postgres_instance_labels" {
  type    = map(string)
  default = {}
}


# This variable determines if databsase is running or not
variable "posgress_activation_policy" {
  default     = "ALWAYS"
  description = "The default activation policy for CloudSQL"
}

variable "database_name" {
  default     = "eddy"
  description = "Name of app database"
}

variable "postgres_name" {
  default     = "eddy"
  description = "Name of app database"
}

variable "database_user" {
  default     = "eddy"
  description = "name os app user"
}

variable "postgres_region" {
  default     = "us-central1"
  description = "cloudsql region"
}

variable "postgres_version" {
  default     = "POSTGRES_11"
  description = "cloudsql db version"
}
