variable "project_name" {
  description = "The name of the project. Used as a prefix on resource names and tags."
  type        = string
}

variable "environment" {
  description = "The deployment environment, e.g. dev, staging, or production."
  type        = string
}

variable "ecs_cluster_name" {
  description = "The name of the existing ECS cluster the service runs in."
  type        = string
}

variable "ecs_service_name" {
  description = "The name of the existing ECS service to auto scale."
  type        = string
}

variable "min_capacity" {
  description = "The minimum number of ECS tasks to keep running."
  type        = number
}

variable "max_capacity" {
  description = "The maximum number of ECS tasks Auto Scaling may scale out to."
  type        = number
}

variable "target_cpu_utilization" {
  description = "The target average CPU utilization percentage the scaling policy tries to maintain."
  type        = number
}
