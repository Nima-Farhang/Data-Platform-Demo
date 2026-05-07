data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  name_prefix = "${var.project}-${var.environment}"
  account_id  = data.aws_caller_identity.current.account_id
  region      = data.aws_region.current.name

  account_root_arn = "arn:aws:iam::${local.account_id}:root"

  platform_admin_principal_arns = length(var.platform_admin_principal_arns) > 0 ? var.platform_admin_principal_arns : [
    local.account_root_arn
  ]

  product_deployment_principal_arns = length(var.product_deployment_principal_arns) > 0 ? var.product_deployment_principal_arns : [
    local.account_root_arn
  ]

  bucket_object_arns = [
    for bucket_arn in values(var.platform_bucket_arns) : "${bucket_arn}/*"
  ]

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

data "aws_iam_policy_document" "platform_admin_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = local.platform_admin_principal_arns
    }
  }
}

data "aws_iam_policy_document" "cicd_account_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [local.account_root_arn]
    }
  }
}

data "aws_iam_policy_document" "cicd_github_assume_role" {
  count = var.github_oidc_provider_arn == null ? 0 : 1

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.github_repository_subjects
    }
  }
}

data "aws_iam_policy_document" "product_deployment_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = local.product_deployment_principal_arns
    }
  }
}

resource "aws_iam_role" "platform_admin" {
  name               = "${local.name_prefix}-platform-admin-role"
  assume_role_policy = data.aws_iam_policy_document.platform_admin_assume_role.json
  description        = "Admin role for shared ${var.environment} platform infrastructure."

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-platform-admin-role"
      Role = "platform-admin"
    }
  )
}

resource "aws_iam_role" "cicd" {
  name = "${local.name_prefix}-cicd-deployment-role"
  assume_role_policy = var.github_oidc_provider_arn == null ? (
    data.aws_iam_policy_document.cicd_account_assume_role.json
    ) : (
    data.aws_iam_policy_document.cicd_github_assume_role[0].json
  )
  description = "CI/CD deployment role for shared ${var.environment} platform infrastructure."

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-cicd-deployment-role"
      Role = "cicd-deployment"
    }
  )
}

resource "aws_iam_role" "product_deployment" {
  name               = "${local.name_prefix}-product-deployment-role"
  assume_role_policy = data.aws_iam_policy_document.product_deployment_assume_role.json
  description        = "Deployment role for data product repositories using shared ${var.environment} platform resources."

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-product-deployment-role"
      Role = "product-deployment"
    }
  )
}

data "aws_iam_policy_document" "platform_admin" {
  statement {
    sid    = "ManageSharedPlatformBuckets"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetBucketLocation",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketVersioning",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketVersioning",
      "s3:PutEncryptionConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:PutObject"
    ]
    resources = concat(values(var.platform_bucket_arns), local.bucket_object_arns)
  }

  statement {
    sid    = "ManageV1Networking"
    effect = "Allow"
    actions = [
      "ec2:AssociateRouteTable",
      "ec2:AttachInternetGateway",
      "ec2:CreateInternetGateway",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:CreateSubnet",
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteRoute",
      "ec2:DeleteRouteTable",
      "ec2:DeleteSubnet",
      "ec2:DeleteTags",
      "ec2:DeleteVpc",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DetachInternetGateway",
      "ec2:DisassociateRouteTable",
      "ec2:ModifySubnetAttribute",
      "ec2:ModifyVpcAttribute"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ManagePlatformLogsAndSecrets"
    effect = "Allow"
    actions = [
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogGroup",
      "logs:DeleteLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:TagResource",
      "secretsmanager:UpdateSecret"
    ]
    resources = [
      "arn:aws:cloudwatch:${local.region}:${local.account_id}:alarm:${local.name_prefix}-*",
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/${local.name_prefix}/*",
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/${local.name_prefix}/*:*",
      "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:${local.name_prefix}/*"
    ]
  }

  statement {
    sid    = "ManagePlatformIamRoles"
    effect = "Allow"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:CreateRole",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListPolicyVersions",
      "iam:ListRolePolicies",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:TagPolicy",
      "iam:TagRole",
      "iam:UpdateAssumeRolePolicy"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:policy/${local.name_prefix}-*",
      "arn:aws:iam::${local.account_id}:role/${local.name_prefix}-*"
    ]
  }
}

data "aws_iam_policy_document" "cicd" {
  source_policy_documents = [data.aws_iam_policy_document.platform_admin.json]
}

data "aws_iam_policy_document" "product_deployment" {
  statement {
    sid    = "UseSharedPlatformBuckets"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = concat(values(var.platform_bucket_arns), local.bucket_object_arns)
  }

  statement {
    sid    = "WriteProductDeploymentLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/${local.name_prefix}/products/*",
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/${local.name_prefix}/products/*:*"
    ]
  }

  statement {
    sid    = "ReadProductDeploymentSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:${local.name_prefix}/products/*"
    ]
  }
}

resource "aws_iam_role_policy" "platform_admin" {
  name   = "${local.name_prefix}-platform-admin-policy"
  role   = aws_iam_role.platform_admin.id
  policy = data.aws_iam_policy_document.platform_admin.json
}

resource "aws_iam_role_policy" "cicd" {
  name   = "${local.name_prefix}-cicd-deployment-policy"
  role   = aws_iam_role.cicd.id
  policy = data.aws_iam_policy_document.cicd.json
}

resource "aws_iam_role_policy" "product_deployment" {
  name   = "${local.name_prefix}-product-deployment-policy"
  role   = aws_iam_role.product_deployment.id
  policy = data.aws_iam_policy_document.product_deployment.json
}
