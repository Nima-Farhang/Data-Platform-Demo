# 0008 — V2 Platform Foundation Expansion

## Status

Accepted

## Context

The initial V1 platform established a deployable AWS foundation with remote state, networking, storage, IAM, logging, secrets, and environment wiring.

The platform now needs to support future event-driven and Iceberg-based data products without moving product workloads into the platform repository. Product repositories need reusable shared outputs, deployment guardrails, auditability, and catalog conventions before they create their own IoT, EventBridge, Lambda, Glue, API Gateway, dbt, Streamlit, and Iceberg resources.

## Decision

Expand the platform foundation to V2 by adding reusable shared capabilities only:

- GitHub OIDC support for platform CI/CD role trust
- reusable product deployment permission boundary
- account-level CloudTrail audit baseline
- platform CloudWatch logging baseline
- optional VPC endpoints for private workloads
- shared Glue Catalog/lakehouse conventions
- optional generic platform Glue database marker
- root outputs intended for product repository onboarding

The platform repository will continue to own shared infrastructure and conventions. Product repositories will own product workloads and business resources.

The following remain product repository responsibilities:

- IoT Core resources
- EventBridge product rules
- Lambda functions
- Glue jobs, crawlers, workflows, and triggers
- API Gateway APIs
- product Glue databases
- product Iceberg tables and table definitions
- dbt projects
- Streamlit applications
- product-specific CI/CD
- business logic, dashboards, and alerts

## Consequences

Product repositories can consume a stronger platform baseline without hardcoding shared infrastructure names or creating unsafe IAM patterns.

The platform provides reusable guardrails and outputs, but it does not become a product workload repository.

Terraform module boundaries must remain explicit. New shared capabilities should be added only when they are reusable across products or required to operate the platform foundation.

Optional cost-increasing features, such as interface VPC endpoints, must remain disabled by default.

## Product Onboarding Outputs

Product repositories should consume platform outputs such as:

- `aws_region`
- `environment`
- `vpc_id`
- `private_subnet_id`
- `vpc_endpoint_ids`
- shared bucket names and ARNs
- `platform_kms_key_arn`
- `product_deployment_role_arn`
- `product_deployment_permission_boundary_policy_arn`
- `product_log_group_base_name`
- `product_log_group_base_arn`
- `lakehouse_catalog_id`
- `lakehouse_curated_bucket_location`
- `lakehouse_naming_conventions`
- `lakehouse_product_database_name_pattern`
- `lakehouse_product_table_location_pattern`

## Related Documents

- `docs/architecture.md`
- `docs/platform-scope.md`
- `docs/module-boundaries.md`
- `docs/security-model.md`
- `docs/product-onboarding.md`
- `docs/adr/0002-platform-product-boundary.md`
- `docs/adr/0007-v1-scope-and-non-goals.md`
