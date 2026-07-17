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
  # project. The colleague account's deployment role needs a bucket policy
  # on this bucket granting cross-account s3:GetObject/PutObject/
  # ListBucket - no DynamoDB permissions needed, since locking is handled
  # by the bucket itself (use_lockfile, in the root terragrunt.hcl).
  state_bucket = "cloud-ops-dashboard-tfstate-902664897239"
  state_region = "us-east-1"

  common_tags = {
    Project   = "cloud-ops-dashboard"
    ManagedBy = "Terragrunt"
  }
}
