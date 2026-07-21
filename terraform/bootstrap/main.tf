data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  state_bucket_name = "${var.project}-terraform-state-${var.state_bucket_suffix}"
  lock_table_name   = "${var.project}-terraform-locks"
  account_id        = data.aws_caller_identity.current.account_id
  region            = data.aws_region.current.name

  github_oidc_provider_url = "https://token.actions.githubusercontent.com"
  github_oidc_subjects_by_environment = {
    for environment in var.deployment_environments : environment => flatten([
      for repository in var.github_allowed_repositories : [
        "repo:${var.github_organization}/${repository}:environment:${environment}"
      ]
    ])
  }
  github_product_deployment_environments = toset([
    for environment in var.deployment_environments : environment
    if length(local.github_oidc_subjects_by_environment[environment]) > 0
  ])
  product_terraform_state_key_patterns_by_environment = {
    for environment in var.deployment_environments : environment => [
      for pattern in var.product_terraform_state_key_patterns : replace(pattern, "<environment>", environment)
    ]
  }
  product_terraform_state_object_arns_by_environment = {
    for environment in var.deployment_environments : environment => [
      for pattern in local.product_terraform_state_key_patterns_by_environment[environment] : "${aws_s3_bucket.terraform_state.arn}/${pattern}"
    ]
  }
  product_terraform_state_list_prefixes_by_environment = {
    for environment in var.deployment_environments : environment => distinct([
      for pattern in local.product_terraform_state_key_patterns_by_environment[environment] : split("*", pattern)[0]
    ])
  }

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
  bucket        = local.state_bucket_name
  force_destroy = var.force_destroy_buckets

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


resource "aws_iam_openid_connect_provider" "github" {
  url             = local.github_oidc_provider_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.github_oidc_thumbprint_list

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-github-oidc-provider"
    }
  )
}

data "aws_iam_policy_document" "github_deployment_assume_role" {
  for_each = toset(var.deployment_environments)

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_oidc_subjects_by_environment[each.key]
    }
  }
}

data "aws_iam_policy_document" "github_deployment" {
  for_each = toset(var.deployment_environments)

  statement {
    sid    = "UseTerraformBackend"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/environments/${each.key}/*"
    ]
  }

  statement {
    sid    = "UseTerraformStateLock"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem"
    ]
    resources = [aws_dynamodb_table.terraform_locks.arn]
  }

  statement {
    sid    = "ReadAwsMetadata"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
      "ec2:Describe*",
      "cloudwatch:Describe*",
      "cloudwatch:List*",
      "logs:Describe*",
      "logs:List*",
      "s3:GetAccountPublicAccessBlock",
      "s3:ListAllMyBuckets",
      "iam:Get*",
      "iam:List*",
      "kms:Describe*",
      "kms:Get*",
      "kms:List*",
      "secretsmanager:ListSecrets",
      "cloudtrail:DescribeTrails",
      "cloudtrail:Get*",
      "cloudtrail:List*",
      "glue:Get*",
      "glue:List*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ManageEnvironmentPlatformInfrastructure"
    effect = "Allow"
    actions = [
      "apigateway:*",
      "cloudtrail:*",
      "cloudwatch:*",
      "ec2:*",
      "events:*",
      "glue:*",
      "iam:*",
      "kms:*",
      "lambda:*",
      "logs:*",
      "s3:*",
      "secretsmanager:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "github_deployment" {
  for_each = toset(var.deployment_environments)

  name               = "${var.project}-${each.key}-cicd-deployment-role"
  assume_role_policy = data.aws_iam_policy_document.github_deployment_assume_role[each.key].json
  description        = "GitHub Actions deployment role for the ${each.key} shared platform environment."

  lifecycle {
    precondition {
      condition     = length(local.github_oidc_subjects_by_environment[each.key]) > 0
      error_message = "Configure at least one GitHub OIDC subject for each deployment environment."
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name        = "${var.project}-${each.key}-cicd-deployment-role"
      Environment = each.key
      Role        = "cicd-deployment"
    }
  )
}

resource "aws_iam_role_policy" "github_deployment" {
  for_each = toset(var.deployment_environments)

  name   = "${var.project}-${each.key}-cicd-deployment-policy"
  role   = aws_iam_role.github_deployment[each.key].id
  policy = data.aws_iam_policy_document.github_deployment[each.key].json
}


data "aws_iam_policy_document" "github_product_deployment_assume_role" {
  for_each = local.github_product_deployment_environments

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_oidc_subjects_by_environment[each.key]
    }
  }
}

data "aws_iam_policy_document" "github_product_deployment" {
  for_each = local.github_product_deployment_environments

  statement {
    sid    = "ListProductTerraformState"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.terraform_state.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = local.product_terraform_state_list_prefixes_by_environment[each.key]
    }
  }

  statement {
    sid    = "UseProductTerraformStateObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = local.product_terraform_state_object_arns_by_environment[each.key]
  }

  statement {
    sid    = "UseTerraformStateLock"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem"
    ]
    resources = [aws_dynamodb_table.terraform_locks.arn]
  }

  statement {
    sid    = "ReadProductDeploymentMetadata"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
      "iam:GetRole",
      "iam:ListAccountAliases"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "AssumeProductDeploymentRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::${local.account_id}:role/${var.project}-${each.key}-product-deployment-role"
    ]
  }
}

resource "aws_iam_role" "github_product_deployment" {
  for_each = local.github_product_deployment_environments

  name               = "${var.project}-${each.key}-product-cicd-deployment-role"
  assume_role_policy = data.aws_iam_policy_document.github_product_deployment_assume_role[each.key].json
  description        = "GitHub Actions product deployment role for ${each.key}; limited to product Terraform state and product deployment role assumption."

  tags = merge(
    local.common_tags,
    {
      Name        = "${var.project}-${each.key}-product-cicd-deployment-role"
      Environment = each.key
      Role        = "product-cicd-deployment"
    }
  )
}

resource "aws_iam_role_policy" "github_product_deployment" {
  for_each = local.github_product_deployment_environments

  name   = "${var.project}-${each.key}-product-cicd-deployment-policy"
  role   = aws_iam_role.github_product_deployment[each.key].id
  policy = data.aws_iam_policy_document.github_product_deployment[each.key].json
}
