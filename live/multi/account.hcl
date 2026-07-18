# live/multi/account.hcl
# -----------------------------------------------------------------------------
# Account-specific values for the COLLEAGUE's AWS account (account ID
# 416069842292). deployment_role_arn is the role created in that account
# per the multi-account setup guide - its trust policy allows the dev
# account's GitHub-Terraform-Deploy-Role (arn:aws:iam::902664897239:role/
# GitHub-Terraform-Deploy-Role) to assume it, which is what Terragrunt's
# generated provider.tf assume_role block actually does at plan/apply time.
#
# "multi" is used here exactly as named in the requested folder structure
# - functionally this is simply "the second AWS account." Rename the
# directory to something more descriptive (e.g. "colleague") any time;
# nothing else references the directory name itself, only its contents.
# -----------------------------------------------------------------------------

locals {
  account_name = "multi"
  account_id   = "416069842292"

  deployment_role_arn = "arn:aws:iam::416069842292:role/Github-Terraform-Deploy-Role"
}
