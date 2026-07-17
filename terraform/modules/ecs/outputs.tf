# modules/ecs/outputs.tf
# -----------------------------------------------------------------------------
# Exposes cluster/service/task-definition identifiers for anything that
# integrates with this module later - Auto Scaling (needs the cluster and
# service names), CloudWatch Alarms (needs the service/cluster names), and
# the GitHub Actions deployment pipeline (needs the task definition family
# to register new revisions against).
# -----------------------------------------------------------------------------

output "ecs_cluster_id" {
  description = "The ID of the ECS cluster."
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster."
  value       = aws_ecs_cluster.main.arn
}

output "ecs_service_name" {
  description = "The name of the ECS service."
  value       = aws_ecs_service.app.name
}

output "ecs_service_arn" {
  description = "The ARN of the ECS service."
  value       = aws_ecs_service.app.arn
}

output "task_definition_arn" {
  description = "The ARN of the ECS task definition."
  value       = aws_ecs_task_definition.app.arn
}

output "task_definition_family" {
  description = "The family name of the ECS task definition. Used by the deployment pipeline to register new revisions."
  value       = aws_ecs_task_definition.app.family
}
