










resource "aws_service_discovery_http_namespace" "internal" {
  name        = "${var.project_name}-${var.environment}.internal"
  description = "Service Connect namespace for internal service-to-service traffic in ${var.project_name}-${var.environment}."

  tags = {
    Name        = "${var.project_name}-${var.environment}-internal-namespace"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
