output "namespace_arn" {
  description = "The ARN of the Cloud Map HTTP namespace used for ECS Service Connect."
  value       = aws_service_discovery_http_namespace.internal.arn
}

output "namespace_id" {
  description = "The ID of the Cloud Map HTTP namespace."
  value       = aws_service_discovery_http_namespace.internal.id
}

output "namespace_name" {
  description = "The name of the Cloud Map HTTP namespace."
  value       = aws_service_discovery_http_namespace.internal.name
}
