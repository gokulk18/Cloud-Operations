# live/dev/us-east-1/region.hcl
# -----------------------------------------------------------------------------
# Region-specific values for the dev account's us-east-1 deployment. Adding
# a second region for this SAME account later is just a new sibling
# directory (e.g. dev/eu-west-1/region.hcl) with its own module configs -
# account.hcl one level up is unaffected.
# -----------------------------------------------------------------------------

locals {
  aws_region = "us-east-1"
}
