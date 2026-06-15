output "log_group_names" {
  description = "Map of platform CloudWatch log group names by purpose."
  value = {
    for purpose, log_group in aws_cloudwatch_log_group.platform : purpose => log_group.name
  }
}

output "log_group_arns" {
  description = "Map of platform CloudWatch log group ARNs by purpose."
  value = {
    for purpose, log_group in aws_cloudwatch_log_group.platform : purpose => log_group.arn
  }
}

output "platform_log_group_name" {
  description = "Name of the shared platform runtime log group."
  value       = aws_cloudwatch_log_group.platform["platform"].name
}

output "platform_log_group_arn" {
  description = "ARN of the shared platform runtime log group."
  value       = aws_cloudwatch_log_group.platform["platform"].arn
}

output "deployment_log_group_name" {
  description = "Name of the shared platform deployment log group."
  value       = aws_cloudwatch_log_group.platform["deployments"].name
}

output "deployment_log_group_arn" {
  description = "ARN of the shared platform deployment log group."
  value       = aws_cloudwatch_log_group.platform["deployments"].arn
}

output "product_log_group_base_name" {
  description = "Base CloudWatch log group name for product repositories to use when creating product-specific streams or child log groups."
  value       = aws_cloudwatch_log_group.platform["products"].name
}

output "product_log_group_base_arn" {
  description = "Base CloudWatch log group ARN for product repositories."
  value       = aws_cloudwatch_log_group.platform["products"].arn
}

output "platform_error_alarm_names" {
  description = "Names of platform error-count CloudWatch alarms."
  value = {
    for purpose, alarm in aws_cloudwatch_metric_alarm.platform_errors : purpose => alarm.alarm_name
  }
}

output "deployment_failure_alarm_name" {
  description = "Name of the platform deployment failure placeholder alarm."
  value       = aws_cloudwatch_metric_alarm.deployment_failures.alarm_name
}
