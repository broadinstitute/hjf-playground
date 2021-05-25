
#
# Eddy postgres cloudsql instance
#


# Cloud SQL database
module "postgres" {
  source = "github.com/broadinstitute/terraform-shared.git//terraform-modules/cloudsql-postgres?ref=cloudsql-postgres-0.0.1-tf-0.12"

  enable_flag = var.postgres_num_instances > "0" ? "1" : "0"
  providers = {
    google.target = google.eddy
  }
  project                     = var.google_project
  cloudsql_region             = var.postgres_region
  cloudsql_version            = var.postgres_version
  cloudsql_name               = "${var.appname}-${var.infrastructure_id}"
  cloudsql_tier               = var.postgres_tier
  cloudsql_database_name      = var.database_name
  cloudsql_database_user_name = var.database_user
  cloudsql_instance_labels    = var.postgres_instance_labels
}


