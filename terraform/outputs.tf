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

output "platform_admin_role_arn" {
  description = "ARN of the Platform Admin IAM role."
  value       = module.iam.platform_admin_role_arn
}

output "cicd_role_arn" {
  description = "ARN of the CI/CD Deployment IAM role."
  value       = module.iam.cicd_role_arn
}

output "product_deployment_role_arn" {
  description = "ARN of the Product Deployment IAM role."
  value       = module.iam.product_deployment_role_arn
}
