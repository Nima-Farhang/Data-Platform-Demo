output "catalog_id" {
  description = "AWS Glue catalog ID used by this environment."
  value       = local.catalog_id
}

output "curated_bucket_name" {
  description = "Name of the curated S3 bucket used as the lakehouse storage root."
  value       = var.curated_bucket_name
}

output "curated_bucket_arn" {
  description = "ARN of the curated S3 bucket used as the lakehouse storage root."
  value       = var.curated_bucket_arn
}

output "curated_bucket_prefix" {
  description = "Prefix inside the curated bucket reserved for lakehouse data."
  value       = var.curated_bucket_prefix
}

output "curated_bucket_location" {
  description = "S3 URI for the shared curated lakehouse root."
  value       = local.curated_bucket_location
}

output "platform_catalog_database_name" {
  description = "Name of the generic platform Glue database marker, when enabled."
  value       = try(aws_glue_catalog_database.platform[0].name, null)
}

output "platform_catalog_database_arn" {
  description = "ARN of the generic platform Glue database marker, when enabled."
  value       = try(aws_glue_catalog_database.platform[0].arn, null)
}

output "naming_conventions" {
  description = "Shared Glue Catalog and Iceberg storage naming conventions for product repositories."
  value       = local.naming_conventions
}

output "product_database_name_pattern" {
  description = "Naming convention product repositories should use for Glue databases."
  value       = var.product_database_name_pattern
}

output "product_table_location_pattern" {
  description = "S3 location convention product repositories should use for Iceberg table roots."
  value       = var.product_table_location_pattern
}
