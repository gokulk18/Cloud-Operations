

include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

terraform {
  source = "../../../../terraform/modules/alb"
}

dependency "vpc" {
  config_path                             = "../vpc"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    vpc_id            = "vpc-00000000000000000"
    public_subnet_ids = ["subnet-00000000000000001", "subnet-00000000000000002"]
  }
}

dependency "security" {
  config_path                             = "../security"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    alb_security_group_id = "sg-00000000000000000"
  }
}

inputs = {
  project_name = local.common_vars.locals.project_name
  environment  = local.account_vars.locals.account_name

  aws_region          = local.region_vars.locals.aws_region
  deployment_role_arn = local.account_vars.locals.deployment_role_arn

  vpc_id                 = dependency.vpc.outputs.vpc_id
  public_subnet_ids      = dependency.vpc.outputs.public_subnet_ids
  alb_security_group_id  = dependency.security.outputs.alb_security_group_id

  application_port = 3000
}
