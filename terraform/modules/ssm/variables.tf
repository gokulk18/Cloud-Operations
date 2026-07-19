






variable "image_parameter_name" {
  description = "The name of the existing SSM Parameter Store parameter holding the container image URI, e.g. /ecs/frontend-image-uri."
  type        = string
}
