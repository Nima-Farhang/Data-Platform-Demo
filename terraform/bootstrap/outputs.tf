output "state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.arn
}

output "lock_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking."
  value       = aws_dynamodb_table.terraform_locks.name
}

output "lock_table_arn" {
  description = "ARN of the DynamoDB table used for Terraform state locking."
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "aws_region" {
  description = "AWS region where the bootstrap resources were created."
  value       = var.aws_region
}



output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider used by bootstrap deployment roles."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_deployment_role_arns" {
  description = "Map of GitHub Actions deployment role ARNs by environment. Use these as AWS_DEPLOY_ROLE_ARN GitHub Environment secrets."
  value       = { for environment, role in aws_iam_role.github_deployment : environment => role.arn }
}


output "github_product_deployment_role_arns" {
  description = "Map of product-scoped GitHub Actions deployment role ARNs by environment. Product repositories use these for backend access and then assume the product deployment role."
  value       = { for environment, role in aws_iam_role.github_product_deployment : environment => role.arn }
}

output "product_terraform_state_key_patterns_by_environment" {
  description = "Approved product Terraform state key patterns by environment."
  value       = local.product_terraform_state_key_patterns_by_environment
}
