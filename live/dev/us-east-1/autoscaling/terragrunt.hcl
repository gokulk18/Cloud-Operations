include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

terraform {
  source = "../../../../terraform/modules/autoscaling"
}

dependency "ecs" {
  config_path                             = "../ecs"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    ecs_cluster_name = "mock-cluster"
    ecs_service_name = "mock-service"
  }
}

inputs = {
  project_name = local.common_vars.locals.project_name
  environment  = local.account_vars.locals.account_name

  aws_region          = local.region_vars.locals.aws_region
  deployment_role_arn = local.account_vars.locals.deployment_role_arn

  ecs_cluster_name = dependency.ecs.outputs.ecs_cluster_name
  ecs_service_name = dependency.ecs.outputs.ecs_service_name

  min_capacity           = 1
  max_capacity           = 4
  target_cpu_utilization = 60
}
