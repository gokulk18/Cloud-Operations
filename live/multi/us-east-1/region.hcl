# live/multi/us-east-1/region.hcl
# -----------------------------------------------------------------------------
# Region-specific values for the colleague account's us-east-1 deployment.
# Identical structure to dev/us-east-1/region.hcl - this is what "the
# infrastructure deployed into both accounts must be identical, only
# configuration values differ" looks like in practice: the module code
# and the terragrunt.hcl files are the same shape, only the values in
# account.hcl/region.hcl change.
# -----------------------------------------------------------------------------

locals {
  aws_region = "us-east-1"
}
