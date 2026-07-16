
output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets."
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway."
  value       = module.vpc.nat_gateway_id
}

output "public_route_table_id" {
  description = "The ID of the public route table."
  value       = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  description = "The ID of the private route table."
  value       = module.vpc.private_route_table_id
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group."
  value       = module.security_groups.alb_security_group_id
}

output "ecs_security_group_id" {
  description = "The ID of the ECS security group."
  value       = module.security_groups.ecs_security_group_id
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer."
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "The public DNS name of the Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "The hosted zone ID of the Application Load Balancer."
  value       = module.alb.alb_zone_id
}

output "target_group_arn" {
  description = "The ARN of the target group ECS tasks will register into."
  value       = module.alb.target_group_arn
}

output "listener_arn" {
  description = "The ARN of the HTTP listener."
  value       = module.alb.listener_arn
}
