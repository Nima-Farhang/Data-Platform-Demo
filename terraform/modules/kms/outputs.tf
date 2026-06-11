output "key_id" {
  description = "KMS key ID for shared platform encryption."
  value       = aws_kms_key.platform.key_id
}

output "key_arn" {
  description = "KMS key ARN for shared platform encryption."
  value       = aws_kms_key.platform.arn
}

output "alias_name" {
  description = "KMS alias name for the shared platform key."
  value       = aws_kms_alias.platform.name
}

output "alias_arn" {
  description = "KMS alias ARN for the shared platform key."
  value       = aws_kms_alias.platform.arn
}
