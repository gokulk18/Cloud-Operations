locals {
  name_prefix = "${var.project_name}-${var.environment}"

  ecs_resource_id = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
}

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
