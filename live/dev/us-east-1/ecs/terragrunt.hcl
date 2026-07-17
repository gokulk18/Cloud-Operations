# live/dev/us-east-1/ecs/terragrunt.hcl
# -----------------------------------------------------------------------------
# Depends on VPC, Security, IAM, ALB exactly as requested, PLUS SSM
# (image_uri - see the correction note at the top of this response) and
# Service Discovery (the Service Connect namespace this module requires).
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
  source = "../../../../terraform/modules/ecs"
}

dependency "vpc" {
  config_path                             = "../vpc"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    private_subnet_ids = ["subnet-00000000000000003", "subnet-00000000000000004"]
  }
}

dependency "security" {
  config_path                             = "../security"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    ecs_security_group_id = "sg-00000000000000001"
  }
}

dependency "iam" {
  config_path                             = "../iam"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    task_execution_role_arn = "arn:aws:iam::000000000000:role/mock-execution"
    task_role_arn            = "arn:aws:iam::000000000000:role/mock-task"
  }
}

dependency "alb" {
  config_path                             = "../alb"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:000000000000:targetgroup/mock/0000000000000000"
  }
}

dependency "ssm" {
  config_path                             = "../ssm"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    image_uri = "ghcr.io/example/example:mock"
  }
}

dependency "service_discovery" {
  config_path                             = "../service-discovery"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    namespace_arn = "arn:aws:servicediscovery:us-east-1:000000000000:namespace/mock"
  }
}

inputs = {
  project_name = local.common_vars.locals.project_name
  environment  = local.account_vars.locals.account_name

  aws_region          = local.region_vars.locals.aws_region
  deployment_role_arn = local.account_vars.locals.deployment_role_arn

  private_subnet_ids      = dependency.vpc.outputs.private_subnet_ids
  ecs_security_group_id   = dependency.security.outputs.ecs_security_group_id
  task_execution_role_arn = dependency.iam.outputs.task_execution_role_arn
  task_role_arn            = dependency.iam.outputs.task_role_arn
  target_group_arn         = dependency.alb.outputs.target_group_arn
  image_uri                = dependency.ssm.outputs.image_uri

  service_connect_namespace_arn = dependency.service_discovery.outputs.namespace_arn
  service_connect_port_name     = "frontend"

  container_name = "frontend"
  container_port = 3000
  cpu            = 256
  memory         = 512
}
