locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_cloudwatch_metric_alarm" "running_task_count" {
  alarm_name          = "${local.name_prefix}-ecs-running-task-count"
  alarm_description   = "Triggers when the ECS service has zero running tasks."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  treat_missing_data  = "breaching"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = {
    Name        = "${local.name_prefix}-ecs-running-task-count-alarm"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${local.name_prefix}-alb-5xx-errors"
  alarm_description   = "Triggers when the ALB returns more than 10 HTTP 5xx responses in a 1-minute period."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = {
    Name        = "${local.name_prefix}-alb-5xx-errors-alarm"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
