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
