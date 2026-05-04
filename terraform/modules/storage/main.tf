locals {
  name_prefix = "${var.project}-${var.environment}"

  bucket_names = {
    raw       = "${local.name_prefix}-raw-${var.account_suffix}"
    logs      = "${local.name_prefix}-logs-${var.account_suffix}"
    artifacts = "${local.name_prefix}-artifacts-${var.account_suffix}"
  }

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

resource "aws_s3_bucket" "platform" {
  for_each = local.bucket_names

  bucket = each.value

  tags = merge(
    local.common_tags,
    {
      Name    = each.value
      Purpose = "platform-${each.key}"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "platform" {
  for_each = aws_s3_bucket.platform

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "platform" {
  for_each = aws_s3_bucket.platform

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "platform" {
  for_each = aws_s3_bucket.platform

  bucket = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}
