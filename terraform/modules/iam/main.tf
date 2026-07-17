# modules/iam/main.tf
# -----------------------------------------------------------------------------
# Creates the two IAM roles an ECS Fargate task needs: the Task Execution
# Role (used by ECS itself to launch the task) and the Task Role (used by
# the application code inside the container). No policies are attached to
# the Task Role - it starts empty and gets permissions added later, only as
# the application actually needs them.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Data source: Trust policy shared by both roles
# -----------------------------------------------------------------------------
# Defines WHO is allowed to assume these roles: only the ECS tasks service
# itself, never a person or another AWS account. Built with
# aws_iam_policy_document instead of raw JSON so Terraform can validate its
# structure at plan time.
data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# -----------------------------------------------------------------------------
# Resource: ECS Task Execution Role
# -----------------------------------------------------------------------------
# Assumed by the ECS agent (not your application code) to launch the task:
# pulling the container image and sending logs to CloudWatch.
resource "aws_iam_role" "task_execution" {
  name               = "${var.project_name}-${var.environment}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-task-execution-role"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# Resource: Attach the AWS-managed execution policy
# -----------------------------------------------------------------------------
# AmazonECSTaskExecutionRolePolicy grants exactly what the execution role
# needs (ECR image pulls, CloudWatch Logs, container metadata) and is
# maintained by AWS, so it stays correct as ECS itself evolves.
resource "aws_iam_role_policy_attachment" "task_execution_managed" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -----------------------------------------------------------------------------
# Resource: ECS Task Role
# -----------------------------------------------------------------------------
# Assumed by the application code running inside the container for any AWS
# API calls it makes itself. Intentionally has no policies attached yet -
# permissions (e.g. SSM Parameter Store, Secrets Manager) get added in a
# later phase, only as the application actually needs them.
resource "aws_iam_role" "task_role" {
  name               = "${var.project_name}-${var.environment}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-task-role"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
