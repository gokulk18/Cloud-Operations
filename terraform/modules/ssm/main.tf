# modules/ssm/main.tf
# -----------------------------------------------------------------------------
# Reads an existing SSM Parameter Store parameter at plan time. This module
# creates or modifies nothing - aws_ssm_parameter (the resource) is
# deliberately never used here, only the data source. The parameter is
# owned and written by the image-build CI/CD pipeline, not by Terraform.
# -----------------------------------------------------------------------------

data "aws_ssm_parameter" "image" {
  name = var.image_parameter_name
}
