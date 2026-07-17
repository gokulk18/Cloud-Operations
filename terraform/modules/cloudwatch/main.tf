# modules/cloudwatch/main.tf
# -----------------------------------------------------------------------------
# Creates two CloudWatch metric alarms that monitor the health of the
# existing ECS Fargate application: one for "no tasks running", one for
# "the ALB is returning server-side errors". Neither alarm notifies anyone
# yet - no SNS topic is attached - they only evaluate and change state,
# ready for a future notification phase to hook into.
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# Resource: Running ECS Task Count Alarm
# -----------------------------------------------------------------------------
# Fires when the service has zero running tasks - the clearest possible
# signal that the application is completely down. Missing data is treated
# as breaching, since a gap in this metric (e.g. the service itself
# disappearing) is just as much a problem as an explicit zero.
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

# -----------------------------------------------------------------------------
# Resource: ALB 5XX Error Alarm
# -----------------------------------------------------------------------------
# Fires when the ALB itself returns more than 10 HTTP 5xx responses within a
# minute. Missing data is treated as not breaching, since the normal,
# healthy state is zero 5xx responses (which CloudWatch may report as no
# data points at all, not literal zeros) - that should never be mistaken
# for an alarm condition.
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
