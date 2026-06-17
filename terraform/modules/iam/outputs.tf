output "platform_admin_role_name" {
  description = "Name of the Platform Admin IAM role."
  value       = aws_iam_role.platform_admin.name
}

output "platform_admin_role_arn" {
  description = "ARN of the Platform Admin IAM role."
  value       = aws_iam_role.platform_admin.arn
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


