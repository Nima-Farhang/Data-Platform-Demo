locals {
  name_prefix = "${var.project}-${var.environment}"

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

resource "aws_secretsmanager_secret" "placeholder" {
  name        = "${local.name_prefix}/platform/placeholderV1"
  description = "Placeholder secret for the ${var.environment} platform baseline. Replace outside source control."

  tags = merge(
    local.common_tags,
    {
      Name    = "${local.name_prefix}/platform/placeholderV1"
      Purpose = "platform-placeholder"
    }
  )
}

resource "aws_secretsmanager_secret_version" "placeholder" {
  secret_id = aws_secretsmanager_secret.placeholder.id
  secret_string = jsonencode({
    placeholder = true
    value       = "replace-outside-source-control"
  })
}
