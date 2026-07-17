# live/dev/us-east-1/service-discovery/terragrunt.hcl
# -----------------------------------------------------------------------------
# NOT one of your 8 modules - added because the ecs module (unmodified)
# has a required service_connect_namespace_arn input with no default.
# Creates the Cloud Map namespace that input needs. No dependencies.
# -----------------------------------------------------------------------------

include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

terraform {
  source = "../../../../terraform/modules/service-discovery"
}

inputs = {
  project_name = local.common_vars.locals.project_name
  environment  = local.account_vars.locals.account_name

  aws_region          = local.region_vars.locals.aws_region
  deployment_role_arn = local.account_vars.locals.deployment_role_arn
}
