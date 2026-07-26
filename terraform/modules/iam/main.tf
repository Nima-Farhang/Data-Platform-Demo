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

  product_resource_name_prefix            = var.product_resource_name_prefix != null ? var.product_resource_name_prefix : "${local.name_prefix}-product-"
  product_service_safe_name_prefix        = replace(local.product_resource_name_prefix, "-", "_")
  product_glue_database_name_prefix       = var.product_glue_database_name_prefix != null ? var.product_glue_database_name_prefix : "${replace(var.project, "-", "_")}_${var.environment}_"
  product_terraform_state_key_pattern     = "environments/${var.environment}/products/*/*.tfstate"
  product_permission_boundary_policy_name = "${local.name_prefix}-product-deployment-permission-boundary"
  product_permission_boundary_policy_arn  = "arn:aws:iam::${local.account_id}:policy/${local.product_permission_boundary_policy_name}"
  platform_catalog_database_name          = var.platform_catalog_database_name != null ? var.platform_catalog_database_name : "${replace(var.project, "-", "_")}_${var.environment}_platform"


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


resource "aws_iam_role" "product_deployment" {
  name                 = "${local.name_prefix}-product-deployment-role"
  assume_role_policy   = data.aws_iam_policy_document.product_deployment_assume_role.json
  description          = "Deployment role for data product repositories using shared ${var.environment} platform resources."
  permissions_boundary = aws_iam_policy.product_deployment_permission_boundary.arn

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

  statement {
    sid    = "ManagePlatformGlueCatalogMarker"
    effect = "Allow"
    actions = [
      "glue:CreateDatabase",
      "glue:DeleteDatabase",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:TagResource",
      "glue:UntagResource",
      "glue:UpdateDatabase"
    ]
    resources = [
      "arn:aws:glue:${local.region}:${local.account_id}:catalog",
      "arn:aws:glue:${local.region}:${local.account_id}:database/${local.platform_catalog_database_name}"
    ]
  }
}


data "aws_iam_policy_document" "product_deployment_permission_boundary" {
  statement {
    effect = "Allow"
    actions = [
      "apigateway:GET",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "ec2:Describe*",
      "events:List*",
      "glue:Get*",
      "glue:List*",
      "iam:Get*",
      "iam:List*",
      "iot:DescribeEndpoint",
      "iot:List*",
      "lambda:Get*",
      "lambda:List*",
      "logs:Describe*",
      "logs:List*",
      "s3:GetAccountPublicAccessBlock",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "sts:GetCallerIdentity"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "iot:CreateTopicRule",
      "iot:DeleteTopicRule",
      "iot:DisableTopicRule",
      "iot:EnableTopicRule",
      "iot:GetTopicRule",
      "iot:ReplaceTopicRule",
      "iot:TagResource",
      "iot:UntagResource"
    ]
    resources = [
      "arn:aws:iot:${local.region}:${local.account_id}:rule/${local.product_resource_name_prefix}*",
      "arn:aws:iot:${local.region}:${local.account_id}:rule/${local.product_service_safe_name_prefix}*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "events:CreateEventBus",
      "events:DeleteEventBus",
      "events:DescribeEventBus",
      "events:PutEvents",
      "events:TagResource",
      "events:UntagResource"
    ]
    resources = [
      "arn:aws:events:${local.region}:${local.account_id}:event-bus/${local.product_resource_name_prefix}*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "glue:BatchCreatePartition",
      "glue:BatchDeletePartition",
      "glue:BatchGetPartition",
      "glue:CreateDatabase",
      "glue:CreatePartition",
      "glue:CreateTable",
      "glue:DeleteDatabase",
      "glue:DeletePartition",
      "glue:DeleteTable",
      "glue:TagResource",
      "glue:UntagResource",
      "glue:UpdateDatabase",
      "glue:UpdatePartition",
      "glue:UpdateTable"
    ]
    resources = [
      "arn:aws:glue:${local.region}:${local.account_id}:catalog",
      "arn:aws:glue:${local.region}:${local.account_id}:database/${local.product_glue_database_name_prefix}*",
      "arn:aws:glue:${local.region}:${local.account_id}:table/${local.product_glue_database_name_prefix}*/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DeleteDashboards",
      "cloudwatch:PutDashboard",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:TagResource",
      "cloudwatch:UntagResource"
    ]
    resources = [
      "arn:aws:cloudwatch:${local.region}:${local.account_id}:alarm:${local.product_resource_name_prefix}*",
      "arn:aws:cloudwatch::${local.account_id}:dashboard/${local.product_resource_name_prefix}*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "cloudwatch:namespace"
      values = [
        "${local.product_resource_name_prefix}*",
        "DataPlatform/Products/*"
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "events:*Rule",
      "events:*Targets*",
      "events:DescribeRule",
      "events:TagResource",
      "events:UntagResource",
      "glue:*Job*",
      "glue:StartJobRun",
      "glue:TagResource",
      "glue:UntagResource",
      "lambda:*Function*",
      "lambda:*Alias",
      "lambda:AddPermission",
      "lambda:PublishVersion",
      "lambda:RemovePermission",
      "lambda:TagResource",
      "lambda:UntagResource"
    ]
    resources = [
      "arn:aws:events:${local.region}:${local.account_id}:event-bus/${local.product_resource_name_prefix}*",
      "arn:aws:events:${local.region}:${local.account_id}:rule/${local.product_resource_name_prefix}*",
      "arn:aws:events:${local.region}:${local.account_id}:rule/${local.product_resource_name_prefix}*/*",
      "arn:aws:events:${local.region}:${local.account_id}:rule/*/${local.product_resource_name_prefix}*",
      "arn:aws:glue:${local.region}:${local.account_id}:job/${local.product_resource_name_prefix}*",
      "arn:aws:lambda:${local.region}:${local.account_id}:function:${local.product_resource_name_prefix}*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:*LogGroup",
      "logs:*LogStream",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
      "logs:TagLogGroup",
      "logs:UntagLogGroup"
    ]
    resources = [
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/${local.name_prefix}/products/${local.product_resource_name_prefix}*",
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/${local.name_prefix}/products/${local.product_resource_name_prefix}*:*",
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${local.product_resource_name_prefix}*",
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${local.product_resource_name_prefix}*:*",
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws-glue/jobs/${local.product_resource_name_prefix}*",
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws-glue/jobs/${local.product_resource_name_prefix}*:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "apigateway:DELETE",
      "apigateway:PATCH",
      "apigateway:POST",
      "apigateway:PUT",
      "apigateway:TagResource",
      "apigateway:UntagResource"
    ]
    resources = [
      "arn:aws:apigateway:${local.region}::/apis*",
      "arn:aws:apigateway:${local.region}::/restapis*",
      "arn:aws:apigateway:${local.region}::/tags/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:GetRole*",
      "iam:ListRolePolicies",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateRole*"
    ]
    resources = ["arn:aws:iam::${local.account_id}:role/${local.product_resource_name_prefix}*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${local.account_id}:role/${local.product_resource_name_prefix}*"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values = [
        "apigateway.amazonaws.com",
        "events.amazonaws.com",
        "glue.amazonaws.com",
        "lambda.amazonaws.com"
      ]
    }
  }

  statement {
    effect = "Deny"
    actions = [
      "iam:CreateRole",
      "iam:PutRolePermissionsBoundary"
    ]
    resources = ["arn:aws:iam::${local.account_id}:role/${local.product_resource_name_prefix}*"]

    condition {
      test     = "StringNotEquals"
      variable = "iam:PermissionsBoundary"
      values   = [local.product_permission_boundary_policy_arn]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue"
    ]
    resources = concat(
      values(var.platform_bucket_arns),
      local.bucket_object_arns,
      [
        "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/${local.name_prefix}/products/*",
        "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/${local.name_prefix}/products/*:*",
        "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:${local.name_prefix}/products/*"
      ]
    )
  }

}

resource "aws_iam_policy" "product_deployment_permission_boundary" {
  name        = local.product_permission_boundary_policy_name
  description = "Permission boundary for product deployment roles in the ${var.environment} data platform."
  policy      = data.aws_iam_policy_document.product_deployment_permission_boundary.json

  lifecycle {
    precondition {
      condition     = length(replace(data.aws_iam_policy_document.product_deployment_permission_boundary.json, "/\\s/", "")) <= 6144
      error_message = "Product deployment permission boundary must not exceed the AWS managed policy size limit of 6144 characters."
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = local.product_permission_boundary_policy_name
      Role = "product-deployment-boundary"
    }
  )
}

data "aws_iam_policy_document" "product_deployment" {
  source_policy_documents = [data.aws_iam_policy_document.product_deployment_permission_boundary.json]

  statement {
    sid    = "ReadDeploymentMetadata"
    effect = "Allow"
    actions = [
      "apigateway:GET",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "ec2:Describe*",
      "events:List*",
      "glue:Get*",
      "glue:List*",
      "iam:Get*",
      "iam:List*",
      "iot:DescribeEndpoint",
      "iot:List*",
      "lambda:Get*",
      "lambda:List*",
      "logs:Describe*",
      "logs:List*",
      "s3:GetAccountPublicAccessBlock",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "sts:GetCallerIdentity"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "platform_admin" {
  name   = "${local.name_prefix}-platform-admin-policy"
  role   = aws_iam_role.platform_admin.id
  policy = data.aws_iam_policy_document.platform_admin.json
}


resource "aws_iam_role_policy" "product_deployment" {
  name   = "${local.name_prefix}-product-deployment-policy"
  role   = aws_iam_role.product_deployment.id
  policy = data.aws_iam_policy_document.product_deployment.json
}
