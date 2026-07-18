# live/common.hcl
# -----------------------------------------------------------------------------
# Values true across EVERY account and EVERY region - the project name,
# and the centralized state bucket/lock table both accounts share. Nothing
# account-specific (account_id, deployment_role_arn) or region-specific
# (aws_region) belongs here - see account.hcl and region.hcl for those.
# -----------------------------------------------------------------------------

locals {
  project_name = "cloud-ops-dashboard"

  # Reuses the same S3 bucket already created for the original terraform/
  # project. No cross-account bucket policy is needed for the colleague
  # account: the remote_state block in live/terragrunt.hcl has no role_arn
  # of its own, so state reads/writes always run under whichever
  # credentials the pipeline already has active (the dev account's hub
  # role, which owns this bucket) - the colleague account's
  # deployment_role_arn is only ever used by the generated aws provider
  # block, for actual resource operations, never for state. No DynamoDB
  # permissions needed either, since locking is handled by the bucket
  # itself (use_lockfile, in the root terragrunt.hcl).
  state_bucket = "cloud-ops-dashboard-tfstate-902664897239"
  state_region = "us-east-1"

  common_tags = {
    Project   = "cloud-ops-dashboard"
    ManagedBy = "Terragrunt"
  }
}
