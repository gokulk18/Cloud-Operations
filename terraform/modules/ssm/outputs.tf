# modules/ssm/outputs.tf
# -----------------------------------------------------------------------------
# Exposes the parameter's value so the root module can pass it into the ecs
# module as image_uri, without the ecs module needing any knowledge of SSM
# at all.
# -----------------------------------------------------------------------------

output "image_uri" {
  description = "The container image URI read from SSM Parameter Store."
  # insecure_value (not value) deliberately - the AWS provider marks
  # .value as sensitive unconditionally, for every parameter type, even
  # plain (non-SecureString) ones like this image URI. insecure_value is
  # the same data, without that marking - appropriate here since this
  # parameter genuinely holds no secret. Using .value would fail under
  # Terragrunt specifically, since here this module runs as its own
  # standalone root (not a nested child module in one combined root, as
  # in the original design), and Terraform requires any ROOT module
  # output touching a sensitive value to be explicitly annotated.
  value = data.aws_ssm_parameter.image.insecure_value
}
