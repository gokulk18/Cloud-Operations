
variable "aws_region" {
  description = "The AWS region where all resources will be created, e.g. us-east-1."
  type        = string
}

variable "project_name" {
  description = "The name of the project. Used as a prefix on resource names and tags."
  type        = string
}

variable "environment" {
  description = "The deployment environment, e.g. dev, staging, or production."
  type        = string
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC, e.g. 10.0.0.0/16."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets, one per subnet."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets, one per subnet."
  type        = list(string)
}

variable "application_port" {
  description = "The TCP port the ECS Fargate application listens on. The ALB forwards traffic to ECS tasks on this port."
  type        = number
}

variable "image_ssm_parameter_name" {
  description = "The name of the SSM Parameter Store parameter holding the container image URI to deploy, e.g. /ecs/frontend-image-uri."
  type        = string
}

variable "container_name" {
  description = "The name of the container within the ECS task definition."
  type        = string
}

variable "cpu" {
  description = "The number of CPU units to reserve for the ECS task (Fargate CPU value, e.g. 256 = 0.25 vCPU)."
  type        = number
}

variable "memory" {
  description = "The amount of memory (in MiB) to reserve for the ECS task (e.g. 512)."
  type        = number
}

variable "min_capacity" {
  description = "The minimum number of ECS tasks Auto Scaling keeps running."
  type        = number
}

variable "max_capacity" {
  description = "The maximum number of ECS tasks Auto Scaling may scale out to."
  type        = number
}

variable "target_cpu_utilization" {
  description = "The target average CPU utilization percentage the Auto Scaling policy tries to maintain."
  type        = number
}
