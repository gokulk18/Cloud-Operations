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

output "alb_arn_suffix" {
  description = "The ARN suffix of the ALB (e.g. app/<name>/<id>), the format CloudWatch's LoadBalancer dimension requires - distinct from the full ARN."
  value       = aws_lb.main.arn_suffix
}

output "target_group_arn" {
  description = "The ARN of the target group. The ECS service will register its tasks into this target group."
  value       = aws_lb_target_group.app.arn
}

output "listener_arn" {
  description = "The ARN of the HTTP listener."
  value       = aws_lb_listener.http.arn
}
