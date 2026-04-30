locals {
  state_bucket_name = "${var.project}-terraform-state-${var.state_bucket_suffix}"
  lock_table_name   = "${var.project}-terraform-locks"

  common_tags = merge(
    {
      Project    = "Data Platform Demo"
      Owner      = var.owner
      CostCenter = var.cost_center
      ManagedBy  = "Terraform"
    },
    var.additional_tags
  )
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.state_bucket_name

  lifecycle {
    precondition {
      condition     = length(local.state_bucket_name) <= 63
      error_message = "Terraform state bucket name must be 63 characters or fewer."
    }

    precondition {
      condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", local.state_bucket_name))
      error_message = "Terraform state bucket name must be a valid S3 bucket name."
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = local.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
}
