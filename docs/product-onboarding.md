# Product Repository Onboarding

## Purpose

This guide explains how a data product repository should use the shared infrastructure deployed by Data Platform Demo.

The platform repository provides reusable AWS foundations, guardrails, and outputs. A product repository uses those outputs to create product-owned resources in its own Terraform state.

The guiding rule remains:

> The platform repository owns shared infrastructure. Product repositories own product workloads.

## Audience

Use this guide when creating or updating a product repository that needs to deploy workloads on top of the shared platform foundation.

This includes products that plan to use IoT Core, EventBridge, Lambda, Glue, API Gateway, Iceberg tables, dbt, Streamlit, or other product-specific services.

## Before You Start

Confirm the platform environment you want to use has been deployed successfully.

The platform team should provide:

- AWS account ID and region
- target environment, such as `dev`, `test`, or `prod`
- access method for reading platform Terraform outputs
- product deployment role ARN or role assumption instructions
- product deployment permission boundary policy ARN
- naming prefix or product identifier to use
- required tags for product resources
- any environment-specific restrictions

The product repository should have:

- its own Terraform state backend
- its own CI/CD workflow
- product-specific Terraform modules or configuration
- product-specific IAM policies constrained by the platform permission boundary
- a product owner and cost allocation value

## Responsibilities

The product repository owns product resources and business logic.

Product-owned resources include:

- IoT Core resources
- EventBridge product rules
- Lambda functions
- Glue jobs, crawlers, workflows, and triggers
- API Gateway APIs
- product Glue databases
- product Iceberg tables and table definitions
- dbt projects
- Streamlit applications
- product-specific secrets, dashboards, and alarms

The platform repository owns shared resources and conventions.

Shared platform resources include:

- VPC and subnet IDs
- optional VPC endpoint IDs
- shared S3 buckets
- platform KMS key
- deployment roles and permission boundary
- CloudWatch platform log groups
- CloudTrail audit baseline
- Glue Catalog and lakehouse naming conventions

## Onboarding Steps

1. Choose the target platform environment.

   Product repositories should deploy separately for `dev`, `test`, and `prod`. Do not share product Terraform state across environments.

2. Read the platform outputs.

   Product repositories should consume platform outputs through a documented mechanism, such as Terraform remote state, pipeline variables, or an approved output export process. Do not hardcode bucket names, role ARNs, subnet IDs, KMS ARNs, or catalog IDs.

3. Configure product naming.

   Use a stable product identifier in resource names. Product resource names should follow platform conventions and remain clearly separate from shared platform resources.

   Recommended pattern:

   ```text
   <project>-<environment>-product-<product-name>-<component>
   ```

   Glue database names should follow the exported lakehouse database pattern.

4. Configure required tags.

   Product resources should include the platform tag set plus product-specific ownership tags where useful.

   Required shared tags:

   - `Project`
   - `Environment`
   - `Owner`
   - `CostCenter`
   - `ManagedBy`

5. Configure the product deployment role.

   Product repositories should use the exported product deployment role or create product-specific deployment roles that attach the exported permission boundary.

   Product-specific deployment roles should set:

   ```hcl
   permissions_boundary = var.product_deployment_permission_boundary_policy_arn
   ```

6. Create product IAM roles and policies.

   Product IAM roles should be named using the product prefix and should grant only the permissions needed by the product workload.

   Product roles should not be able to administer platform IAM, CloudTrail, shared platform buckets, or platform KMS policies.

7. Create product workload resources.

   Create product-owned IoT Core, EventBridge, Lambda, Glue, API Gateway, dbt, Streamlit, and application resources in the product repository.

   Keep product-specific lifecycle, deployment, alerting, and rollback behavior in the product repository.

8. Create product catalog resources.

   Product repositories should create their own Glue databases and Iceberg tables using the exported lakehouse conventions.

   The platform may create a generic environment marker database, but product tables do not belong there.

9. Configure product observability.

   Use the exported product log group base where appropriate, but create product-specific log groups, metric filters, dashboards, and alarms in the product repository.

10. Validate and deploy through product CI/CD.

   Product CI/CD should run formatting, validation, plan, approval, and apply for product-owned Terraform only.

## Platform Outputs To Consume

### Environment And Network

Use these outputs to place workloads in the correct AWS environment and network:

- `aws_region`
- `environment`
- `vpc_id`
- `vpc_cidr_block`
- `private_subnet_id`
- `public_subnet_id`, only when public placement is explicitly required
- `vpc_endpoint_ids`, when private workloads need endpoint awareness
- `gateway_vpc_endpoint_ids`
- `interface_vpc_endpoint_ids`
- `vpc_endpoint_security_group_id`

Private workloads should prefer the private subnet. Do not add NAT Gateway or additional network controls in a product repository unless that product has an approved requirement and ownership model.

### Shared Storage

Use these outputs for shared platform bucket access:

- `raw_bucket_name`
- `raw_bucket_arn`
- `curated_bucket_name`
- `curated_bucket_arn`
- `artifacts_bucket_name`
- `artifacts_bucket_arn`
- `logs_bucket_name`
- `logs_bucket_arn`
- `platform_bucket_names`
- `platform_bucket_arns`

Product repositories should create product-specific prefixes or objects, not new shared platform buckets.

Recommended product S3 layout:

```text
s3://<bucket>/<environment>/products/<product-name>/...
```

For Iceberg data, follow the lakehouse table location pattern exported by the platform.

### KMS

Use this output when product resources need to encrypt data using the platform key:

- `platform_kms_key_arn`

Product repositories must not modify platform KMS key policy, disable the key, revoke platform grants, or schedule deletion.

### IAM And Deployment

Use these outputs for product deployment and IAM guardrails:

- `product_deployment_role_arn`
- `product_deployment_permission_boundary_policy_arn`
- `platform_admin_role_arn`, for platform team use only
- `cicd_role_arn`, for platform CI/CD use only

Product repositories should not use platform admin roles for product deployment.

When creating product-specific deployment roles, attach the permission boundary:

```hcl
resource "aws_iam_role" "product_deployment" {
  name                 = "data-platform-dev-product-orders-deployment-role"
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  permissions_boundary = var.product_deployment_permission_boundary_policy_arn
}
```

### Logging And Monitoring

Use these outputs for logging conventions:

- `platform_log_group_names`
- `platform_log_group_arns`
- `platform_runtime_log_group_name`
- `platform_runtime_log_group_arn`
- `platform_deployment_log_group_name`
- `platform_deployment_log_group_arn`
- `product_log_group_base_name`
- `product_log_group_base_arn`
- `platform_error_alarm_names`
- `platform_deployment_failure_alarm_name`

Product repositories should create their own workload-specific alarms for Lambda, Glue, API Gateway, IoT Core, dbt, Streamlit, and product applications.

### Secrets

Use these outputs to follow platform secret naming conventions:

- `placeholder_secret_name`
- `placeholder_secret_arn`

Product repositories should create and manage product-specific secrets through approved secure processes. Do not commit real secret values to Git.

### Audit

Use these outputs when documenting audit and compliance behavior:

- `cloudtrail_trail_name`
- `cloudtrail_trail_arn`
- `cloudtrail_log_bucket_name`
- `cloudtrail_log_bucket_prefix`
- `cloudtrail_log_bucket_arn`

Product repositories should not create product-specific CloudTrail trails unless a separate compliance requirement explicitly calls for it.

### Lakehouse And Glue Catalog

Use these outputs for Glue Catalog and Iceberg conventions:

- `lakehouse_catalog_id`
- `lakehouse_curated_bucket_location`
- `lakehouse_curated_bucket_prefix`
- `lakehouse_platform_catalog_database_name`
- `lakehouse_platform_catalog_database_arn`
- `lakehouse_naming_conventions`
- `lakehouse_product_database_name_pattern`
- `lakehouse_product_table_location_pattern`

Product repositories should create their own product Glue databases and product Iceberg tables.

Example product database naming flow:

```text
Pattern: <project>_<environment>_<product>
Example: data_platform_dev_orders
```

Example Iceberg table root:

```text
s3://<curated-bucket>/<curated-prefix>/products/orders/data_platform_dev_orders/events/
```

## Terraform Remote State Example

A product repository can consume platform outputs through Terraform remote state when approved by the platform team.

Example:

```hcl
data "terraform_remote_state" "platform" {
  backend = "s3"

  config = {
    bucket         = var.platform_state_bucket
    key            = var.platform_state_key
    region         = var.aws_region
    dynamodb_table = var.platform_lock_table
  }
}

locals {
  platform = data.terraform_remote_state.platform.outputs
}
```

Then reference outputs through `local.platform`:

```hcl
resource "aws_glue_catalog_database" "product" {
  catalog_id = local.platform.lakehouse_catalog_id
  name       = "data_platform_dev_orders"
}
```

Only grant product repositories read access to platform state when that access is approved. If direct remote state access is not appropriate, publish required outputs through CI/CD variables, parameter store, or another approved mechanism.

## Product Glue Database Example

Product repositories own product Glue databases.

```hcl
resource "aws_glue_catalog_database" "product" {
  catalog_id   = local.platform.lakehouse_catalog_id
  name         = "data_platform_dev_orders"
  description  = "Orders product database for dev."
  location_uri = "${local.platform.lakehouse_curated_bucket_location}products/orders/data_platform_dev_orders/"
}
```

Do not create product databases in the platform repository.

## Product Iceberg Table Example

Product repositories own Iceberg table definitions.

The exact table resource depends on the chosen engine and Terraform provider. Regardless of implementation, product tables should use:

- `lakehouse_catalog_id`
- product database name
- `lakehouse_product_table_location_pattern`
- the curated bucket location exported by the platform

Do not define product Iceberg tables in the platform repository.

## Product Logging Example

Product repositories can use the exported product log base to choose consistent names.

Example log group name:

```text
/aws/data-platform-dev/products/orders/ingestion
```

Product repositories own retention choices, metric filters, alarms, and dashboards for product workloads unless a shared platform standard says otherwise.

## Product CI/CD Checklist

A product repository pipeline should usually run:

1. `terraform fmt -check`
2. `terraform validate`
3. `terraform plan`
4. review and approval
5. `terraform apply`
6. product tests or smoke checks

The pipeline should assume the approved product deployment role and stay within the exported permission boundary.

## Security Checklist

Before deploying a product repository, confirm:

- product Terraform state is separate from platform state
- no real secrets are committed to Git
- product deployment roles use the platform permission boundary
- product resources follow naming and tagging standards
- product IAM policies are least privilege
- product resources do not alter shared platform bucket policies or KMS key policies
- product Glue databases and Iceberg tables are created in product Terraform, not platform Terraform
- product-specific alarms are created in product Terraform

## What Not To Do

Do not use a product repository to create or modify:

- platform VPC or shared subnets
- platform KMS key policy
- platform CloudTrail trail
- shared platform bucket policies
- platform IAM admin roles
- GitHub OIDC provider configuration
- platform logging baseline
- generic platform Glue database marker

Do not add these product resources to the platform repository:

- IoT Core product resources
- EventBridge product rules
- Lambda functions
- Glue jobs or crawlers
- API Gateway product APIs
- product Iceberg tables
- dbt projects
- Streamlit apps
- product dashboards

## Handoff Checklist

The platform team should provide each product team with:

- target environment
- AWS region and account ID
- platform output access method
- product naming prefix
- required tags
- product deployment role or role creation guidance
- permission boundary policy ARN
- bucket and lakehouse conventions
- logging and secrets conventions
- approval process for additional shared platform needs

The product team should provide:

- product name and owner
- expected AWS services
- required network placement
- required shared bucket access
- expected data classification
- deployment pipeline location
- support and escalation contact
