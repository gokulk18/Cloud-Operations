# modules/ssm/outputs.tf
# -----------------------------------------------------------------------------
# Exposes the parameter's value so the root module can pass it into the ecs
# module as image_uri, without the ecs module needing any knowledge of SSM
# at all.
# -----------------------------------------------------------------------------

output "image_uri" {
  description = "The container image URI read from SSM Parameter Store."
  value       = data.aws_ssm_parameter.image.value
}
