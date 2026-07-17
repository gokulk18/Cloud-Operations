
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}


module "security_groups" {
  source = "./modules/security-groups"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  application_port = var.application_port
  backend_port     = var.backend_container_port
}


module "alb" {
  source = "./modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  application_port      = var.application_port
}

# IAM is a global, account-level service - this module needs no VPC or
# networking inputs, only naming/tagging context.
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
}

# Reads the container image URI at plan time, rather than hardcoding it, so
# a new image can be deployed by updating the SSM parameter (e.g. from the
# GitHub Actions pipeline) without editing this Terraform code at all.
# Creates no resources - it only reads an existing parameter.
module "ssm" {
  source = "./modules/ssm"

  image_parameter_name = var.image_ssm_parameter_name
}

# Reads the backend's image URI the same way - a separate module instance
# since it points at a different SSM parameter, but the same reusable
# module code.
module "ssm_backend" {
  source = "./modules/ssm"

  image_parameter_name = var.backend_image_ssm_parameter_name
}

# The namespace both the frontend and backend ECS services join for
# Service Connect - created once, shared by both.
module "service_discovery" {
  source = "./modules/service-discovery"

  project_name = var.project_name
  environment  = var.environment
}

# The ECS module reuses the private subnets, ECS security group, target
# group, and IAM role ARNs from the modules above - all passed in as
# outputs of those modules, never re-declared as separate root variables.
# This instance is the internet-facing frontend: it registers with the ALB
# target group AND joins Service Connect under the alias "frontend" (unused
# by anything today, but keeps every ecs module instance configured
# uniformly).
module "ecs" {
  source = "./modules/ecs"

  project_name                  = var.project_name
  environment                   = var.environment
  private_subnet_ids            = module.vpc.private_subnet_ids
  ecs_security_group_id         = module.security_groups.ecs_security_group_id
  target_group_arn              = module.alb.target_group_arn
  task_execution_role_arn       = module.iam.task_execution_role_arn
  task_role_arn                 = module.iam.task_role_arn
  image_uri                     = module.ssm.image_uri
  container_name                = var.container_name
  container_port                = var.application_port
  cpu                           = var.cpu
  memory                        = var.memory
  service_connect_namespace_arn = module.service_discovery.namespace_arn
  service_connect_port_name     = "frontend"
}

# A second instance of the SAME ecs module, for the internal backend
# service. No target_group_arn - the ALB never routes to this service
# directly, only the frontend does, over Service Connect. The "-backend"
# suffix on environment keeps this instance's resource names (cluster, log
# group, service) distinct from the frontend's, without touching the
# frontend's already-applied resource names at all.
module "ecs_backend" {
  source = "./modules/ecs"

  project_name                  = var.project_name
  environment                   = "${var.environment}-backend"
  private_subnet_ids            = module.vpc.private_subnet_ids
  ecs_security_group_id         = module.security_groups.ecs_security_group_id
  task_execution_role_arn       = module.iam.task_execution_role_arn
  task_role_arn                 = module.iam.task_role_arn
  image_uri                     = module.ssm_backend.image_uri
  container_name                = var.backend_container_name
  container_port                = var.backend_container_port
  cpu                           = var.cpu
  memory                        = var.memory
  service_connect_namespace_arn = module.service_discovery.namespace_arn
  service_connect_port_name     = "backend"
}

# The autoscaling module reuses the cluster and service names from
# module.ecs's own outputs - it registers and scales that existing service,
# it does not create or modify the service itself.
module "autoscaling" {
  source = "./modules/autoscaling"

  project_name           = var.project_name
  environment            = var.environment
  ecs_cluster_name       = module.ecs.ecs_cluster_name
  ecs_service_name       = module.ecs.ecs_service_name
  min_capacity           = var.min_capacity
  max_capacity           = var.max_capacity
  target_cpu_utilization = var.target_cpu_utilization
}

# The cloudwatch module reuses the ECS cluster/service names and the ALB
# ARN suffix from the modules above - it only observes those existing
# resources, it creates no ECS or ALB resources itself.
module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name     = var.project_name
  environment      = var.environment
  ecs_cluster_name = module.ecs.ecs_cluster_name
  ecs_service_name = module.ecs.ecs_service_name
  alb_arn_suffix   = module.alb.alb_arn_suffix
}
