# modules/alb/main.tf
# -----------------------------------------------------------------------------
# Creates the Application Load Balancer, its Target Group, and the HTTP
# Listener that connects them. The ECS service (a future module) will
# register its tasks into the target group created here - this module has
# no knowledge of ECS itself.
# -----------------------------------------------------------------------------

# A single shared prefix for naming and tagging, so it isn't repeated in
# every resource block below.
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# Resource: Application Load Balancer
# -----------------------------------------------------------------------------
# The internet-facing entry point to the application. It lives in the public
# subnets (so it can reach, and be reached via, the Internet Gateway) and
# uses the ALB security group created in the security-groups module.
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"

  subnets         = var.public_subnet_ids
  security_groups = [var.alb_security_group_id]

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name        = "${local.name_prefix}-alb"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# Resource: Target Group
# -----------------------------------------------------------------------------
# A routable set of targets the ALB forwards traffic to and health-checks.
# target_type = "ip" is required for ECS Fargate tasks, which have their own
# elastic network interface rather than being registered as EC2 instances.
resource "aws_lb_target_group" "app" {
  name        = "${local.name_prefix}-tg"
  port        = var.application_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    path                = var.health_check_path
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
  }

  tags = {
    Name        = "${local.name_prefix}-tg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# Resource: HTTP Listener
# -----------------------------------------------------------------------------
# Listens on port 80 and forwards every request to the target group above.
# The future ECS service doesn't need to know this exists - it only needs
# the target group ARN to register its tasks into.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  tags = {
    Name        = "${local.name_prefix}-http-listener"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
