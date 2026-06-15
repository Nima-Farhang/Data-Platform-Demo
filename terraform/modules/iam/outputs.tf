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

output "product_deployment_permission_boundary_policy_arn" {
  description = "ARN of the reusable permission boundary policy for product deployment roles."
  value       = aws_iam_policy.product_deployment_permission_boundary.arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider used by the CI/CD role, when configured."
  value       = local.github_oidc_provider_arn
}

output "github_repository_subjects" {
  description = "GitHub OIDC subject patterns allowed to assume the CI/CD role."
  value       = local.github_repository_subjects
}
