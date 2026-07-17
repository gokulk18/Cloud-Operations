# live/dev/account.hcl
# -----------------------------------------------------------------------------
# Account-specific values for the DEVELOPMENT account (your own AWS
# account, 902664897239). Every module under dev/us-east-1/ reads this
# file via find_in_parent_folders("account.hcl"), which correctly finds it
# one or two levels up from any module's own directory.
# -----------------------------------------------------------------------------

locals {
  account_name = "dev"
  account_id   = "902664897239"

  # The real, already-existing role from the earlier GitHub Actions phase
  # of this project (created for terraform.yml's OIDC auth). Its name
  # differs from the illustrative "TerraformDeployRole" in the request -
  # functionally identical, just already deployed under a different name.
  # Rename/recreate it as TerraformDeployRole if you want exact naming
  # parity with the colleague account below.
  deployment_role_arn = "arn:aws:iam::902664897239:role/GitHub-Terraform-Deploy-Role"
}
