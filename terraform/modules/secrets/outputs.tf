output "placeholder_secret_name" {
  description = "Name of the platform placeholder secret."
  value       = aws_secretsmanager_secret.placeholder.name
}

output "placeholder_secret_arn" {
  description = "ARN of the platform placeholder secret."
  value       = aws_secretsmanager_secret.placeholder.arn
}
