





output "task_execution_role_arn" {
  description = "The ARN of the ECS Task Execution Role. Used as the Task Definition's execution_role_arn."
  value       = aws_iam_role.task_execution.arn
}

output "task_execution_role_name" {
  description = "The name of the ECS Task Execution Role."
  value       = aws_iam_role.task_execution.name
}

output "task_role_arn" {
  description = "The ARN of the ECS Task Role. Used as the Task Definition's task_role_arn."
  value       = aws_iam_role.task_role.arn
}

output "task_role_name" {
  description = "The name of the ECS Task Role. Needed later to attach application-specific permissions."
  value       = aws_iam_role.task_role.name
}
