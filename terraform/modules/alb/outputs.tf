# modules/alb/outputs.tf
# -----------------------------------------------------------------------------
# Exposes IDs/ARNs the future ECS module (and anything else, like Route 53 or
# CloudWatch) will need to reference without knowing how this module builds
# the ALB internally.
# -----------------------------------------------------------------------------

output "alb_arn" {
  description = "The ARN of the Application Load Balancer."
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "The public DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "The hosted zone ID of the Application Load Balancer, needed for Route 53 alias records."
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "The ARN of the target group. The ECS service will register its tasks into this target group."
  value       = aws_lb_target_group.app.arn
}

output "listener_arn" {
  description = "The ARN of the HTTP listener."
  value       = aws_lb_listener.http.arn
}
