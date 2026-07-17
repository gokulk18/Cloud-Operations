# live/dev/us-east-1/iam/terragrunt.hcl
# -----------------------------------------------------------------------------
# Per the requested dependency list, IAM depends on VPC. The iam module's
# own variables (project_name, environment only) never actually reference
# any VPC output, so this dependency block exists purely to force
# Terragrunt to run VPC before IAM during `run --all` - a valid use of
# `dependency`, just not one that feeds any data through. If you'd rather
# match the real project exactly (where IAM has no dependencies, since
# it's a global service), delete this block and the vpc_id line.
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
  source = "../../../../terraform/modules/iam"
}

dependency "vpc" {
  config_path                             = "../vpc"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
  }
}

inputs = {
  project_name = local.common_vars.locals.project_name
  environment  = local.account_vars.locals.account_name

  aws_region          = local.region_vars.locals.aws_region
  deployment_role_arn = local.account_vars.locals.deployment_role_arn
}
