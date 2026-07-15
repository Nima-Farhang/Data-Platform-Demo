# Product Repository Onboarding

This guide explains how a product repository should consume the shared platform foundation created by Data Platform Demo.

The platform repository owns shared infrastructure and guardrails. Product repositories own product workloads, business logic, and product-specific Terraform state.

## Before You Start

Confirm the target platform environment has been deployed and collect:

- AWS account ID and region
- target environment: `dev`, `test`, or `prod`
- approved method for reading platform outputs
- product-scoped GitHub OIDC deployment role ARN for backend access, when supplied by bootstrap
- product deployment role ARN or role creation guidance
- product deployment permission boundary policy ARN
- exact product resource name prefix
- permitted product Terraform state-key pattern
- naming prefix or product identifier
- required tags
- environment restrictions

The product repository should have its own Terraform state backend, CI/CD workflow, product owner, cost allocation value, and product-specific Terraform configuration.

## Onboarding Steps

1. Choose the target platform environment.

   Keep product state separate for `dev`, `test`, and `prod`.

2. Read platform outputs.

   Use Terraform remote state, CI/CD variables, parameter store, or another approved export process. Do not hardcode bucket names, role ARNs, subnet IDs, KMS ARNs, or catalog IDs.

3. Configure naming and tags.

   Use a stable product identifier and follow [Standards](standards.md). A common product resource pattern is:

   ```text
   <project>-<environment>-product-<product-name>-<component>
   ```

4. Configure deployment access.

   Product CI/CD should use the product-scoped GitHub OIDC deployment role exported by bootstrap when one is available. That role is only for product Terraform backend access and assuming the environment product deployment role. Do not use the broad platform CI/CD deployment role for product repositories.

   Use the exported product deployment role for product Terraform applies, or create a product-specific deployment role with the exported permission boundary:

   ```hcl
   permissions_boundary = var.product_deployment_permission_boundary_policy_arn
   ```

5. Create product resources.

   Product Terraform owns workload resources such as Lambda, Glue jobs, EventBridge rules, API Gateway APIs, product Glue databases, Iceberg tables, dbt deployment resources, Streamlit app resources, product alarms, and product secrets.

6. Validate and deploy through product CI/CD.

   Product pipelines should run formatting, validation, plan, approval, apply, and product tests or smoke checks for product-owned infrastructure only.

## Platform Outputs To Consume

### Environment and Network

- `aws_region`
- `environment`
- `vpc_id`
- `vpc_cidr_block`
- `private_subnet_id`
- `public_subnet_id`, only when public placement is explicitly approved
- `vpc_endpoint_ids`
- `gateway_vpc_endpoint_ids`
- `interface_vpc_endpoint_ids`
- `vpc_endpoint_security_group_id`

Private workloads should prefer private subnet placement. Product repositories should not add NAT Gateway or shared network controls unless ownership and cost are explicitly approved.

### Storage

- `raw_bucket_name` / `raw_bucket_arn`
- `curated_bucket_name` / `curated_bucket_arn`
- `artifacts_bucket_name` / `artifacts_bucket_arn`
- `logs_bucket_name` / `logs_bucket_arn`
- `platform_bucket_names`
- `platform_bucket_arns`

Product repositories create product-specific prefixes or objects, not new shared platform buckets.

Recommended product S3 layout:

```text
s3://<bucket>/<environment>/products/<product-name>/...
```

### KMS and IAM

- `platform_kms_key_arn`
- `product_deployment_role_arn`
- `product_deployment_permission_boundary_policy_arn`
- `product_resource_name_prefix`
- `product_glue_database_name_prefix`
- `product_terraform_state_key_pattern`
- bootstrap `github_product_deployment_role_arns`, when product-scoped GitHub OIDC roles are configured
- bootstrap `product_terraform_state_key_patterns_by_environment`
- `platform_admin_role_arn`, for platform team use only
- `cicd_role_arn` or bootstrap `github_deployment_role_arns`, for platform CI/CD use only

Product repositories must not modify platform KMS policies, shared IAM admin roles, CloudTrail, shared bucket administration, or networking. Product-owned AWS resources must use the exported `product_resource_name_prefix`; product Glue databases must use `product_glue_database_name_prefix`.

### Logging, Secrets, and Audit

- `platform_log_group_names`
- `platform_log_group_arns`
- `product_log_group_base_name`
- `product_log_group_base_arn`
- `placeholder_secret_name`
- `placeholder_secret_arn`
- `cloudtrail_trail_name`
- `cloudtrail_trail_arn`
- `cloudtrail_log_bucket_name`
- `cloudtrail_log_bucket_prefix`
- `cloudtrail_log_bucket_arn`

Product repositories own workload-specific log groups, metric filters, alarms, dashboards, secret values, and rotations.

### Lakehouse and Glue Catalog

- `lakehouse_catalog_id`
- `lakehouse_curated_bucket_location`
- `lakehouse_curated_bucket_prefix`
- `lakehouse_platform_catalog_database_name`
- `lakehouse_platform_catalog_database_arn`
- `lakehouse_naming_conventions`
- `lakehouse_product_database_name_pattern`
- `lakehouse_product_table_location_pattern`

Product repositories create their own Glue databases and Iceberg tables.

Example database pattern:

```text
Pattern: <project>_<environment>_<product>
Example: data_platform_dev_orders
```

## Remote State Example

When approved, a product repository can consume platform outputs through Terraform remote state:

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

Only grant product repositories read access to platform state when that access is approved. Otherwise publish required outputs through CI/CD variables, parameter store, or another approved mechanism.

## Product Terraform State

Product state must stay in approved product key patterns and must not reuse platform environment state keys.

Default approved pattern:

```text
environments/<environment>/products/*/*.tfstate
```

For Event-Driven-Lakehouse-Demo, the expected keys are:

```text
environments/<environment>/products/event-driven-lakehouse/aws.tfstate
environments/<environment>/products/event-driven-lakehouse/snowflake.tfstate
```

Product-scoped GitHub OIDC roles created by bootstrap can access only the configured product state-key patterns and the Terraform lock table. They can assume the environment product deployment role; they cannot administer shared platform infrastructure.

## Security Checklist

Before deployment, confirm:

- product Terraform state is separate from platform state and uses the approved product state-key pattern
- no real secrets are committed to Git
- product CI/CD uses a product-scoped OIDC role, not the broad platform CI/CD role
- product deployment roles use the platform permission boundary
- product resources follow naming and tagging standards, including `product_resource_name_prefix`
- product IAM roles keep the exported permission boundary attached
- product IAM policies are least privilege
- product resources do not alter shared platform buckets, KMS keys, IAM admin roles, CloudTrail, platform logging, or networking
- product Glue databases, tables, jobs, and alarms are created in product Terraform

## Handoff Checklist

Platform team provides target environment, region/account, output access method, product naming guidance, required tags, deployment role or boundary guidance, storage/lakehouse conventions, logging/secrets conventions, and approval process for new shared needs.

Product team provides product name, owner, expected AWS services, network placement needs, shared bucket access needs, data classification, pipeline location, and support contact.
