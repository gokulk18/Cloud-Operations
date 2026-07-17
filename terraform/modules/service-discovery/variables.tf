# modules/service-discovery/variables.tf
# -----------------------------------------------------------------------------
# Inputs the service-discovery module needs - just naming/tagging context,
# the same as the iam module. This is account/VPC-scoped, not tied to any
# single ECS service.
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "The name of the project. Used as a prefix on resource names and tags."
  type        = string
}

variable "environment" {
  description = "The deployment environment, e.g. dev, staging, or production."
  type        = string
}
