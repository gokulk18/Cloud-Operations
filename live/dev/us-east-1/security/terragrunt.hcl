# live/dev/us-east-1/security/terragrunt.hcl

include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

terraform {
  source = "../../../../terraform/modules/security-groups"
}

dependency "vpc" {
  config_path                             = "../vpc"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
  }
}

inputs = {
  project_name = local.common_vars.locals.project_name
  environment  = local.account_vars.locals.account_name

  aws_region          = local.region_vars.locals.aws_region
  deployment_role_arn = local.account_vars.locals.deployment_role_arn

  vpc_id            = dependency.vpc.outputs.vpc_id
  application_port  = 3000
  backend_port      = 5000
}
