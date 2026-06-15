output "trail_name" {
  description = "Name of the account-level CloudTrail trail."
  value       = aws_cloudtrail.account.name
}

output "trail_arn" {
  description = "ARN of the account-level CloudTrail trail."
  value       = aws_cloudtrail.account.arn
}

output "log_bucket_name" {
  description = "Name of the S3 bucket receiving CloudTrail logs."
  value       = var.logs_bucket_name
}

output "log_bucket_prefix" {
  description = "S3 prefix where CloudTrail writes audit logs."
  value       = local.cloudtrail_log_prefix
}

output "log_bucket_arn" {
  description = "ARN of the S3 bucket receiving CloudTrail logs."
  value       = var.logs_bucket_arn
}
