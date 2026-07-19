locals {
  project_name = "cloud-ops-dashboard"

  state_bucket = "cloud-ops-dashboard-tfstate-902664897239"
  state_region = "us-east-1"

  common_tags = {
    Project   = "cloud-ops-dashboard"
    ManagedBy = "Terragrunt"
  }
}
