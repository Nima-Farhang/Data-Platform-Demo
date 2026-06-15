output "vpc_id" {
  description = "ID of the dev platform VPC."
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the dev platform VPC."
  value       = module.networking.vpc_cidr_block
}

output "public_subnet_id" {
  description = "ID of the dev public subnet."
  value       = module.networking.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of the dev private subnet."
  value       = module.networking.private_subnet_id
}

output "internet_gateway_id" {
  description = "ID of the dev Internet Gateway."
  value       = module.networking.internet_gateway_id
}

output "aws_region" {
  description = "AWS region for the dev platform deployment."
  value       = var.aws_region
}

output "environment" {
  description = "Environment name for this platform deployment."
  value       = var.environment
}

output "raw_bucket_name" {
  description = "Name of the shared raw platform bucket."
  value       = module.storage.raw_bucket_name
}

output "raw_bucket_arn" {
  description = "ARN of the shared raw platform bucket."
  value       = module.storage.raw_bucket_arn
}

output "logs_bucket_name" {
  description = "Name of the shared logs platform bucket."
  value       = module.storage.logs_bucket_name
}

output "logs_bucket_arn" {
  description = "ARN of the shared logs platform bucket."
  value       = module.storage.logs_bucket_arn
}

output "artifacts_bucket_name" {
  description = "Name of the shared artifacts platform bucket."
  value       = module.storage.artifacts_bucket_name
}

output "artifacts_bucket_arn" {
  description = "ARN of the shared artifacts platform bucket."
  value       = module.storage.artifacts_bucket_arn
}

output "curated_bucket_name" {
  description = "Name of the shared curated platform bucket."
  value       = module.storage.curated_bucket_name
}

output "curated_bucket_arn" {
  description = "ARN of the shared curated platform bucket."
  value       = module.storage.curated_bucket_arn
}

output "platform_bucket_names" {
  description = "Map of shared platform bucket names by purpose."
  value       = module.storage.bucket_names
}

output "platform_bucket_arns" {
  description = "Map of shared platform bucket ARNs by purpose."
  value       = module.storage.bucket_arns
}

output "platform_admin_role_arn" {
  description = "ARN of the Platform Admin IAM role."
  value       = module.iam.platform_admin_role_arn
}

output "cicd_role_arn" {
  description = "ARN of the CI/CD Deployment IAM role."
  value       = module.iam.cicd_role_arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider used by the CI/CD role, when configured."
  value       = module.iam.github_oidc_provider_arn
}

output "github_repository_subjects" {
  description = "GitHub OIDC subject patterns allowed to assume the CI/CD role."
  value       = module.iam.github_repository_subjects
}

output "product_deployment_role_arn" {
  description = "ARN of the Product Deployment IAM role."
  value       = module.iam.product_deployment_role_arn
}

output "product_deployment_permission_boundary_policy_arn" {
  description = "ARN of the reusable permission boundary policy for product deployment roles."
  value       = module.iam.product_deployment_permission_boundary_policy_arn
}

output "platform_kms_key_id" {
  description = "KMS key ID for shared platform encryption."
  value       = module.kms.key_id
}

output "platform_kms_key_arn" {
  description = "KMS key ARN for shared platform encryption."
  value       = module.kms.key_arn
}

output "platform_kms_alias_name" {
  description = "KMS alias name for shared platform encryption."
  value       = module.kms.alias_name
}

output "platform_kms_alias_arn" {
  description = "KMS alias ARN for shared platform encryption."
  value       = module.kms.alias_arn
}

output "placeholder_secret_name" {
  description = "Name of the platform placeholder secret."
  value       = module.secrets.placeholder_secret_name
}

output "placeholder_secret_arn" {
  description = "ARN of the platform placeholder secret."
  value       = module.secrets.placeholder_secret_arn
}

output "cloudtrail_trail_name" {
  description = "Name of the account-level CloudTrail trail."
  value       = module.audit.trail_name
}

output "cloudtrail_trail_arn" {
  description = "ARN of the account-level CloudTrail trail."
  value       = module.audit.trail_arn
}

output "cloudtrail_log_bucket_name" {
  description = "Name of the S3 bucket receiving CloudTrail logs."
  value       = module.audit.log_bucket_name
}

output "cloudtrail_log_bucket_prefix" {
  description = "S3 prefix where CloudTrail writes audit logs."
  value       = module.audit.log_bucket_prefix
}

output "cloudtrail_log_bucket_arn" {
  description = "ARN of the S3 bucket receiving CloudTrail logs."
  value       = module.audit.log_bucket_arn
}
