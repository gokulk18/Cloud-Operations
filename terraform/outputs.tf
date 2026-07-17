# outputs.tf
# -----------------------------------------------------------------------------
# Exposes the small set of values that matter outside this Terraform run:
# what a person needs to reach the app, and what a future module or CI/CD
# pipeline needs to reference (e.g. GitHub Actions forcing a new ECS
# deployment). Every module still wires its own outputs into other modules
# directly inside main.tf (module.vpc.vpc_id, module.alb.target_group_arn,
# etc.) - none of that internal plumbing needs to be re-exposed here.
# -----------------------------------------------------------------------------

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster running the application."
  value       = module.ecs.ecs_cluster_name
}

output "target_group_arn" {
  description = "ARN of the ALB target group ECS tasks register into."
  value       = module.alb.target_group_arn
}
