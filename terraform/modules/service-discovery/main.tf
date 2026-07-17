# modules/service-discovery/main.tf
# -----------------------------------------------------------------------------
# Creates the Cloud Map namespace that ECS Service Connect registers
# services into. This is the one resource every Service-Connect-enabled
# ECS service in this project shares - it's what lets, e.g., the frontend
# service resolve the backend service by a short name instead of an IP.
# -----------------------------------------------------------------------------

# An HTTP namespace (not the older DNS namespace type) is specifically what
# ECS Service Connect requires - it's a lighter-weight Cloud Map namespace
# type built for this exact use case, rather than general-purpose DNS.
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
