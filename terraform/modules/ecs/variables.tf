# modules/ecs/variables.tf
# -----------------------------------------------------------------------------
# Inputs the ecs module needs. Every ID here (subnets, security group, target
# group, IAM roles) comes from resources created in OTHER modules - this
# module never creates or looks any of them up itself, it only consumes the
# IDs it's given.
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "The name of the project. Used as a prefix on resource names and tags."
  type        = string
}

variable "environment" {
  description = "The deployment environment, e.g. dev, staging, or production."
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets the ECS tasks will run in."
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "The ID of the existing security group to attach to the ECS tasks."
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the existing ALB target group the ECS service registers its tasks into. Optional - omit for internal services (like a backend API) that the ALB never routes to directly."
  type        = string
  default     = null
}

variable "task_execution_role_arn" {
  description = "The ARN of the existing ECS Task Execution Role (used by ECS to launch the task)."
  type        = string
}

variable "task_role_arn" {
  description = "The ARN of the existing ECS Task Role (used by the application code at runtime)."
  type        = string
}

variable "image_uri" {
  description = "The full container image URI (e.g. ghcr.io/owner/repo/frontend:sha) to run, read from SSM Parameter Store by the root module."
  type        = string
}

variable "container_name" {
  description = "The name of the container within the task definition."
  type        = string
}

variable "container_port" {
  description = "The port the container listens on. Must match the ALB target group's port."
  type        = number
}

variable "cpu" {
  description = "The number of CPU units to reserve for the task (Fargate CPU value, e.g. 256 = 0.25 vCPU)."
  type        = number
}

variable "memory" {
  description = "The amount of memory (in MiB) to reserve for the task (e.g. 512)."
  type        = number
}

variable "service_connect_namespace_arn" {
  description = "The ARN of the Cloud Map HTTP namespace this service joins for ECS Service Connect - lets other services in the namespace reach it by short name."
  type        = string
}

variable "service_connect_port_name" {
  description = "The short name this service is reachable at within the Service Connect namespace, e.g. \"backend\". Other services reach it via http://<this-name>:<container_port>."
  type        = string
}
