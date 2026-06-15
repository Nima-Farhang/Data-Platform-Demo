output "raw_bucket_name" {
  description = "Name of the shared raw platform bucket."
  value       = aws_s3_bucket.platform["raw"].bucket
}

output "raw_bucket_arn" {
  description = "ARN of the shared raw platform bucket."
  value       = aws_s3_bucket.platform["raw"].arn
}

output "logs_bucket_name" {
  description = "Name of the shared logs platform bucket."
  value       = aws_s3_bucket.platform["logs"].bucket
}

output "logs_bucket_arn" {
  description = "ARN of the shared logs platform bucket."
  value       = aws_s3_bucket.platform["logs"].arn
}

output "artifacts_bucket_name" {
  description = "Name of the shared artifacts platform bucket."
  value       = aws_s3_bucket.platform["artifacts"].bucket
}

output "artifacts_bucket_arn" {
  description = "ARN of the shared artifacts platform bucket."
  value       = aws_s3_bucket.platform["artifacts"].arn
}

output "curated_bucket_name" {
  description = "Name of the shared curated platform bucket."
  value       = aws_s3_bucket.platform["curated"].bucket
}

output "curated_bucket_arn" {
  description = "ARN of the shared curated platform bucket."
  value       = aws_s3_bucket.platform["curated"].arn
}

output "bucket_names" {
  description = "Map of shared platform bucket names by purpose."
  value = {
    for purpose, bucket in aws_s3_bucket.platform : purpose => bucket.bucket
  }
}

output "bucket_arns" {
  description = "Map of shared platform bucket ARNs by purpose."
  value = {
    for purpose, bucket in aws_s3_bucket.platform : purpose => bucket.arn
  }
}
