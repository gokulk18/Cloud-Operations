







data "aws_ssm_parameter" "image" {
  name = var.image_parameter_name
}
