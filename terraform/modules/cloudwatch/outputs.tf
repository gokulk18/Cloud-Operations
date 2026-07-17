# modules/cloudwatch/outputs.tf
# -----------------------------------------------------------------------------
# Exposes the alarm names/ARNs for anything that integrates with this
# module later - a future SNS notification phase would attach
# alarm_actions using these ARNs.
# -----------------------------------------------------------------------------

output "running_task_alarm_name" {
  description = "The name of the running ECS task count alarm."
  value       = aws_cloudwatch_metric_alarm.running_task_count.alarm_name
}

output "alb_5xx_alarm_name" {
  description = "The name of the ALB 5xx error alarm."
  value       = aws_cloudwatch_metric_alarm.alb_5xx.alarm_name
}

output "running_task_alarm_arn" {
  description = "The ARN of the running ECS task count alarm."
  value       = aws_cloudwatch_metric_alarm.running_task_count.arn
}

output "alb_5xx_alarm_arn" {
  description = "The ARN of the ALB 5xx error alarm."
  value       = aws_cloudwatch_metric_alarm.alb_5xx.arn
}
