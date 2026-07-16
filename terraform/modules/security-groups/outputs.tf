

output "alb_security_group_id" {
  description = "The ID of the ALB security group. Attach this to the Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "The ID of the ECS security group. Attach this to the ECS Fargate service's network configuration."
  value       = aws_security_group.ecs.id
}
