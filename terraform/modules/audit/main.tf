data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  name_prefix = "${var.project}-${var.environment}"
  account_id  = data.aws_caller_identity.current.account_id
  region      = data.aws_region.current.name

  trail_name               = "${local.name_prefix}-account-audit-trail"
  trail_arn                = "arn:aws:cloudtrail:${local.region}:${local.account_id}:trail/${local.trail_name}"
  cloudtrail_service       = "cloudtrail.amazonaws.com"
  cloudtrail_log_prefix    = var.cloudtrail_log_prefix
  cloudtrail_bucket_prefix = "${local.cloudtrail_log_prefix}/AWSLogs/${local.account_id}"

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

data "aws_iam_policy_document" "cloudtrail_logs_bucket" {
  statement {
    sid    = "AllowCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = [local.cloudtrail_service]
    }

    actions = ["s3:GetBucketAcl"]

    resources = [var.logs_bucket_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }

  statement {
    sid    = "AllowCloudTrailLogDelivery"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = [local.cloudtrail_service]
    }

    actions = ["s3:PutObject"]

    resources = [
      "${var.logs_bucket_arn}/${local.cloudtrail_bucket_prefix}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = var.logs_bucket_name
  policy = data.aws_iam_policy_document.cloudtrail_logs_bucket.json
}

resource "aws_cloudtrail" "account" {
  name                          = local.trail_name
  s3_bucket_name                = var.logs_bucket_name
  s3_key_prefix                 = local.cloudtrail_log_prefix
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_key_arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = merge(
    local.common_tags,
    {
      Name    = local.trail_name
      Purpose = "account-audit"
    }
  )

  depends_on = [aws_s3_bucket_policy.cloudtrail_logs]
}
