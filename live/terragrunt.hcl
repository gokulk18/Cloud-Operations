









locals {



  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}











remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket  = local.common_vars.locals.state_bucket
    region  = local.common_vars.locals.state_region
    encrypt = true







    key = "${path_relative_to_include()}/terraform.tfstate"





    use_lockfile = true
  }
}














generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.12.0"

      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "6.54.0"
        }
      }
    }

    variable "aws_region" {
      description = "AWS region, injected by Terragrunt from region.hcl."
      type        = string
    }

    variable "deployment_role_arn" {
      description = "The IAM role Terraform assumes before making any AWS API calls, injected by Terragrunt from account.hcl."
      type        = string
    }

    provider "aws" {
      region = var.aws_region





      assume_role {
        role_arn = var.deployment_role_arn
      }

      default_tags {
        tags = ${jsonencode(local.common_vars.locals.common_tags)}
      }
    }
  EOF
}
