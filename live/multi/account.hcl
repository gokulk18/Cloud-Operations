# live/multi/account.hcl
# -----------------------------------------------------------------------------
# Account-specific values for the COLLEAGUE's AWS account. Replace both
# placeholders below with real values before this account's configs can
# actually be applied - I don't have access to your colleague's AWS
# account, so these are intentionally marked, not guessed.
#
# "multi" is used here exactly as named in the requested folder structure
# - functionally this is simply "the second AWS account." Rename the
# directory to something more descriptive (e.g. "colleague") any time;
# nothing else references the directory name itself, only its contents.
# -----------------------------------------------------------------------------

locals {
  account_name = "multi"
  account_id   = "<COLLEAGUE_ACCOUNT_ID>"

  # Must exist in the colleague's account: an IAM role trusting your
  # GitHub OIDC provider (or trusting the dev account's deployment role,
  # if you prefer role-chaining instead of separate OIDC trust per
  # account - both are valid, explained further down).
  deployment_role_arn = "arn:aws:iam::<COLLEAGUE_ACCOUNT_ID>:role/TerraformDeployRole"
}
