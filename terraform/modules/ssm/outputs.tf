






output "image_uri" {
  description = "The container image URI read from SSM Parameter Store."









  value = data.aws_ssm_parameter.image.insecure_value
}
