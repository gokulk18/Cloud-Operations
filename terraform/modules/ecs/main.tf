








locals {
  name_prefix = "${var.project_name}-${var.environment}"
}



data "aws_region" "current" {}







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




  dynamic "load_balancer" {
    for_each = var.target_group_arn != null ? [var.target_group_arn] : []
    content {
      target_group_arn = load_balancer.value
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }





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
