# modules/ssm/variables.tf
# -----------------------------------------------------------------------------
# The single input this module needs: which SSM parameter to read. The
# parameter itself is not created here - it's expected to already exist,
# written by the image-build CI/CD pipeline after each push.
# -----------------------------------------------------------------------------

variable "image_parameter_name" {
  description = "The name of the existing SSM Parameter Store parameter holding the container image URI, e.g. /ecs/frontend-image-uri."
  type        = string
}
