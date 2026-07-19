




include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}




terraform {
  source = "../../../../terraform/modules/vpc"
}

inputs = {
  project_name = local.common_vars.locals.project_name
  environment  = local.account_vars.locals.account_name

  aws_region          = local.region_vars.locals.aws_region
  deployment_role_arn = local.account_vars.locals.deployment_role_arn

  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]

  private_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24",
  ]
}
