# live/dev/us-east-1/ssm-backend/terragrunt.hcl
# -----------------------------------------------------------------------------
# Reads the backend image URI - a separate instance of the same ssm module,
# matching module "ssm_backend" in the real (now-retired) terraform/main.tf.
# This was missing from the original migration; the backend ECS service
# depends on it. No dependencies of its own.
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

  image_parameter_name = "/ecs/backend-image-uri"
}
