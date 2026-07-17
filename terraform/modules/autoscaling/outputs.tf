# modules/autoscaling/outputs.tf
# -----------------------------------------------------------------------------
# Exposes the scalable target ID and policy ARN for anything that
# integrates with this module later - e.g. CloudWatch Alarms referencing
# the same scalable target.
# -----------------------------------------------------------------------------

output "autoscaling_target_id" {
  description = "The resource ID of the Application Auto Scaling target (format: service/<cluster-name>/<service-name>)."
  value       = aws_appautoscaling_target.ecs.id
}

output "autoscaling_policy_arn" {
  description = "The ARN of the target tracking scaling policy."
  value       = aws_appautoscaling_policy.cpu.arn
}
