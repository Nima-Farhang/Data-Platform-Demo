locals {
  name_prefix = "${var.project}-${var.environment}"

  platform_log_groups = {
    platform = {
      name      = "/aws/${local.name_prefix}/platform"
      retention = lookup(var.platform_log_group_retention_days, "platform", var.log_group_retention_days)
      purpose   = "platform-runtime"
    }
    deployments = {
      name      = "/aws/${local.name_prefix}/deployments"
      retention = lookup(var.platform_log_group_retention_days, "deployments", var.log_group_retention_days)
      purpose   = "platform-deployments"
    }
    products = {
      name      = "/aws/${local.name_prefix}/products"
      retention = lookup(var.platform_log_group_retention_days, "products", var.log_group_retention_days)
      purpose   = "product-log-base"
    }
  }

  platform_error_log_group_keys = toset(["platform", "deployments"])

  metric_namespace = "DataPlatform/${var.environment}"

  common_tags = merge(
    {
      Project     = "Data Platform Demo"
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )
}

resource "aws_cloudwatch_log_group" "platform" {
  for_each = local.platform_log_groups

  name              = each.value.name
  retention_in_days = each.value.retention
  kms_key_id        = var.log_group_kms_key_arn

  tags = merge(
    local.common_tags,
    {
      Name    = each.value.name
      Purpose = each.value.purpose
    }
  )
}

resource "aws_cloudwatch_log_metric_filter" "platform_errors" {
  for_each = local.platform_error_log_group_keys

  name           = "${local.name_prefix}-${each.key}-errors"
  log_group_name = aws_cloudwatch_log_group.platform[each.key].name
  pattern        = "ERROR"

  metric_transformation {
    name      = "${each.key}-error-count"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "platform_errors" {
  for_each = aws_cloudwatch_log_metric_filter.platform_errors

  alarm_name          = "${local.name_prefix}-${each.key}-error-count"
  alarm_description   = "Platform ${each.key} log error count exceeded threshold."
  namespace           = local.metric_namespace
  metric_name         = each.value.metric_transformation[0].name
  statistic           = "Sum"
  period              = var.error_alarm_period_seconds
  evaluation_periods  = var.error_alarm_evaluation_periods
  threshold           = var.error_alarm_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_actions

  tags = merge(
    local.common_tags,
    {
      Name    = "${local.name_prefix}-${each.key}-error-count"
      Purpose = "platform-error-alarm"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "deployment_failures" {
  alarm_name          = "${local.name_prefix}-deployment-failures"
  alarm_description   = "Placeholder alarm for platform deployment failure metrics."
  namespace           = local.metric_namespace
  metric_name         = "deployment-failure-count"
  statistic           = "Sum"
  period              = var.error_alarm_period_seconds
  evaluation_periods  = var.error_alarm_evaluation_periods
  threshold           = var.deployment_failure_alarm_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_actions

  tags = merge(
    local.common_tags,
    {
      Name    = "${local.name_prefix}-deployment-failures"
      Purpose = "platform-deployment-alarm"
    }
  )
}
