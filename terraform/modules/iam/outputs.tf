output "platform_admin_role_name" {
  description = "Name of the Platform Admin IAM role."
  value       = aws_iam_role.platform_admin.name
}

output "platform_admin_role_arn" {
  description = "ARN of the Platform Admin IAM role."
  value       = aws_iam_role.platform_admin.arn
}

output "cicd_role_name" {
  description = "Name of the CI/CD Deployment IAM role."
  value       = aws_iam_role.cicd.name
}

output "cicd_role_arn" {
  description = "ARN of the CI/CD Deployment IAM role."
  value       = aws_iam_role.cicd.arn
}

output "product_deployment_role_name" {
  description = "Name of the Product Deployment IAM role."
  value       = aws_iam_role.product_deployment.name
}

output "product_deployment_role_arn" {
  description = "ARN of the Product Deployment IAM role."
  value       = aws_iam_role.product_deployment.arn
}
