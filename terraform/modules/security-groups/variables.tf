

variable "project_name" {
  description = "The name of the project. Used as a prefix on resource names and tags."
  type        = string
}

variable "environment" {
  description = "The deployment environment, e.g. dev, staging, or production."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC the security groups will be created in."
  type        = string
}

variable "application_port" {
  description = "The TCP port the ECS Fargate application listens on. The ALB forwards traffic to ECS tasks on this port."
  type        = number
}
