
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
