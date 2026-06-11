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

resource "aws_kms_key" "platform" {
  description             = "KMS key for shared ${var.environment} Data Platform Demo resources."
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms_key_policy.json

  tags = merge(
    local.common_tags,
    {
      Name    = "${local.name_prefix}-platform-kms"
      Purpose = "platform-kms"
    }
  )
}

resource "aws_kms_alias" "platform" {
  name          = "alias/${local.name_prefix}-platform-kms"
  target_key_id = aws_kms_key.platform.key_id
}

data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "AllowRootUserToManageKey"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "kms:*"
    ]

    resources = ["*"]
  }
}

data "aws_caller_identity" "current" {}
