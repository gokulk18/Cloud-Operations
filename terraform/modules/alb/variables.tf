# modules/alb/variables.tf
# -----------------------------------------------------------------------------
# Inputs the alb module needs. vpc_id, public_subnet_ids, and
# alb_security_group_id all come from resources created in OTHER modules
# (vpc and security-groups) - this module never creates or looks them up
# itself, it just consumes the IDs it's given.
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "The name of the project. Used as a prefix on resource names and tags."
  type        = string
}

variable "environment" {
  description = "The deployment environment, e.g. dev, staging, or production."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC the target group will be created in."
  type        = string
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets the ALB will be deployed into."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "The ID of the existing security group to attach to the ALB."
  type        = string
}

variable "application_port" {
  description = "The TCP port the ECS Fargate application listens on. The target group routes to this port."
  type        = number
}

variable "health_check_path" {
  description = "The path the ALB requests to check target health."
  type        = string
  default     = "/"
}

variable "health_check_healthy_threshold" {
  description = "The number of consecutive successful health checks before a target is considered healthy."
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "The number of consecutive failed health checks before a target is considered unhealthy."
  type        = number
  default     = 3
}

variable "health_check_timeout" {
  description = "The number of seconds to wait for a health check response before considering it failed."
  type        = number
  default     = 5
}

variable "health_check_interval" {
  description = "The number of seconds between each health check."
  type        = number
  default     = 30
}

variable "health_check_matcher" {
  description = "The HTTP response code the health check expects for a target to be considered healthy."
  type        = string
  default     = "200"
}
