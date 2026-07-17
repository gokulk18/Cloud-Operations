# modules/autoscaling/main.tf
# -----------------------------------------------------------------------------
# Registers the existing ECS service as a scalable target and attaches a
# target tracking policy that adjusts its task count to keep average CPU
# utilization near the configured target. Creates no ECS, cluster, or
# CloudWatch resources - those already exist.
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Application Auto Scaling identifies an ECS service with a resource ID in
  # this exact format - not the service ARN.
  ecs_resource_id = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
}

# -----------------------------------------------------------------------------
# Resource: Scalable Target
# -----------------------------------------------------------------------------
# Tells Application Auto Scaling which resource it's allowed to scale (the
# ECS service's desired task count) and the hard min/max bounds it may
# never scale outside of, regardless of what the policy below requests.
resource "aws_appautoscaling_target" "ecs" {
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = local.ecs_resource_id
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity

  tags = {
    Name        = "${local.name_prefix}-ecs-autoscaling-target"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# Resource: Target Tracking Scaling Policy
# -----------------------------------------------------------------------------
# Continuously compares the service's average CPU utilization against the
# target value and adjusts the task count (within the min/max bounds above)
# to keep it there - AWS manages the actual math, this just declares the
# goal.
resource "aws_appautoscaling_policy" "cpu" {
  name               = "${local.name_prefix}-ecs-cpu-target-tracking"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  resource_id        = aws_appautoscaling_target.ecs.resource_id

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.target_cpu_utilization
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
