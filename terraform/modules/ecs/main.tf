# modules/ecs/main.tf
# -----------------------------------------------------------------------------
# Creates the ECS Cluster, Fargate Task Definition, and ECS Service that
# actually run the application container. The service runs in the existing
# private subnets, uses the existing ECS security group, and registers its
# tasks into the existing ALB target group - none of which this module
# creates itself.
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# Used to tell the awslogs log driver which region to ship log events to,
# without needing a separate region variable - the provider already knows.
data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# Resource: CloudWatch Log Group
# -----------------------------------------------------------------------------
# The awslogs log driver requires its target log group to already exist -
# creating it explicitly here (rather than relying on the task creating its
# own at runtime) keeps retention and tagging managed by Terraform.
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.name_prefix}"
  retention_in_days = 30

  tags = {
    Name        = "${local.name_prefix}-ecs-logs"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# Resource: ECS Cluster
# -----------------------------------------------------------------------------
# A logical grouping the Fargate tasks run under. Deliberately minimal - no
# capacity providers, no ECS Exec configuration. Container Insights is
# enabled because the cloudwatch module's running-task-count alarm reads
# from the ECS/ContainerInsights metric namespace, which only publishes
# data when this setting is on.
resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${local.name_prefix}-cluster"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# Resource: Fargate Task Definition
# -----------------------------------------------------------------------------
# The blueprint for a single running task: which image to run, how much
# CPU/memory to reserve, which IAM roles to use, and how to ship logs.
resource "aws_ecs_task_definition" "app" {
  family                   = "${local.name_prefix}-${var.container_name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.image_uri
      essential = true

      portMappings = [
        {
          name          = var.service_connect_port_name
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = data.aws_region.current.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${local.name_prefix}-${var.container_name}-task"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# Resource: ECS Service
# -----------------------------------------------------------------------------
# Keeps the desired number of tasks running, places them in the private
# subnets with no public IP, and (when target_group_arn is supplied)
# registers them into the ALB target group. Also joins the shared Service
# Connect namespace, which is how OTHER services (like the frontend calling
# the backend) reach this one by a short name instead of an IP address.
resource "aws_ecs_service" "app" {
  name             = "${local.name_prefix}-service"
  cluster          = aws_ecs_cluster.main.id
  task_definition  = aws_ecs_task_definition.app.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  # Only emitted when target_group_arn is actually set - internal services
  # with no ALB routing (like the backend) skip this block entirely rather
  # than registering with a target group that has nothing to do with them.
  dynamic "load_balancer" {
    for_each = var.target_group_arn != null ? [var.target_group_arn] : []
    content {
      target_group_arn = load_balancer.value
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  # Registers this service in the shared namespace under
  # service_connect_port_name, so other Service-Connect-enabled services can
  # reach it at http://<service_connect_port_name>:<container_port> - no
  # hardcoded IPs, no separate DNS records to manage by hand.
  service_connect_configuration {
    enabled   = true
    namespace = var.service_connect_namespace_arn

    service {
      port_name      = var.service_connect_port_name
      discovery_name = var.service_connect_port_name

      client_alias {
        port     = var.container_port
        dns_name = var.service_connect_port_name
      }
    }
  }

  deployment_controller {
    type = "ECS"
  }

  tags = {
    Name        = "${local.name_prefix}-service"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
