# live/dev/us-east-1/ssm/terragrunt.hcl
# -----------------------------------------------------------------------------
# Reads the frontend image URI at plan time. No dependencies of its own -
# ECS depends on THIS module's output (corrected from the request's
# "SSM depends on ECS" - see explanation above).
# -----------------------------------------------------------------------------

include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

terraform {
  source = "../../../../terraform/modules/ssm"
}

inputs = {
  aws_region          = local.region_vars.locals.aws_region
  deployment_role_arn = local.account_vars.locals.deployment_role_arn

  image_parameter_name = "/ecs/frontend-image-uri"
}
