






variable "project_name" {
  description = "The name of the project. Used as a prefix on resource names and tags."
  type        = string
}

variable "environment" {
  description = "The deployment environment, e.g. dev, staging, or production."
  type        = string
}

variable "ecs_cluster_name" {
  description = "The name of the existing ECS cluster to monitor."
  type        = string
}

variable "ecs_service_name" {
  description = "The name of the existing ECS service to monitor."
  type        = string
}

variable "alb_arn_suffix" {
  description = "The ARN suffix of the existing ALB (format: app/<name>/<id>), required by CloudWatch's LoadBalancer dimension."
  type        = string
}
