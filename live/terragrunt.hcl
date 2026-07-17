# live/terragrunt.hcl
# -----------------------------------------------------------------------------
# THE root Terragrunt configuration - inherited by every module config in
# every account and region below. This file replaces what
# terraform/versions.tf and terraform/providers.tf used to do for the
# retired Terraform root module: declaring the required provider version
# and configuring the AWS provider, just generated fresh per-module instead
# of written once for a single shared root.
# -----------------------------------------------------------------------------

locals {
  # common.hcl lives in this SAME directory (live/), so
  # find_in_parent_folders() finds it immediately without walking up at
  # all - it searches the current directory first, then parents.
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

# -----------------------------------------------------------------------------
# Remote State
# -----------------------------------------------------------------------------
# One centralized S3 bucket + DynamoDB lock table, shared by BOTH AWS
# accounts (dev and multi/colleague). This is a deliberate design choice,
# not an accident: cross-account remote state normally means either (a) one
# shared "state" account both deploy roles can reach via a bucket policy,
# or (b) a separate bucket per account. Design (a) is what's implemented
# here, since it needs no second bucket to provision - see the explanation
# on cross-account bucket access further down.
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

    # path_relative_to_include() already encodes account, region, AND
    # module into one string - e.g. for
    # live/dev/us-east-1/vpc/terragrunt.hcl it evaluates to
    # "dev/us-east-1/vpc". No separate lookup of account.hcl is needed
    # just to keep state files apart; this one function call does it for
    # every account/region/module combination that will ever exist.
    key = "${path_relative_to_include()}/terraform.tfstate"

    # S3 native locking (Terraform >= 1.10) instead of DynamoDB - the
    # bucket itself handles locking via conditional writes, no separate
    # table to provision or pay for. Same mechanism already used by the
    # real terraform/versions.tf backend block.
    use_lockfile = true
  }
}

# -----------------------------------------------------------------------------
# Provider + Required Providers Generation
# -----------------------------------------------------------------------------
# Generates BOTH the required_providers block (previously in
# terraform/versions.tf, at the now-retired root) and the aws provider
# block (previously terraform/providers.tf) into every module's own
# working directory. Two new Terraform variables are declared here -
# aws_region and deployment_role_arn - completely separate from anything
# in the actual modules' own variables.tf files. Every module's
# terragrunt.hcl supplies real values for both via `inputs`, read from
# THAT module's own region.hcl/account.hcl (which this root file cannot
# reach itself - region.hcl and account.hcl are children of live/, and
# find_in_parent_folders() only ever searches upward).
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

      # This is Terraform's OWN native role assumption mechanism - the
      # assume_role block on the aws provider. Terragrunt does not have
      # a separate, magic role-assumption system; it just generates this
      # standard Terraform construct, parameterized per account.
      assume_role {
        role_arn = var.deployment_role_arn
      }

      default_tags {
        tags = ${jsonencode(local.common_vars.locals.common_tags)}
      }
    }
  EOF
}
