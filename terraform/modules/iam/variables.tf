# modules/iam/variables.tf
# -----------------------------------------------------------------------------
# Inputs the iam module needs. IAM is a global AWS service, not tied to a VPC
# or region, so unlike the other modules this one takes no networking IDs -
# only naming/tagging context.
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "The name of the project. Used as a prefix on resource names and tags."
  type        = string
}

variable "environment" {
  description = "The deployment environment, e.g. dev, staging, or production."
  type        = string
}
