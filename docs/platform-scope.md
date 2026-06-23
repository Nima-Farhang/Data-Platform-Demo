# Platform Scope

This document defines what Data Platform Demo owns and what must remain in product repositories.

## Ownership Rule

Shared infrastructure belongs in this platform repository. Workload-specific infrastructure and business logic belong in product repositories.

## Platform Responsibilities

Data Platform Demo owns reusable AWS foundations and guardrails:

- Terraform remote state bootstrap resources
- environment structure for `dev`, `test`, and `prod`
- VPC networking baseline and optional VPC endpoints
- shared S3 buckets for raw, curated, logs, and artifacts data
- platform KMS key
- IAM roles, GitHub OIDC support, and product deployment permission boundary
- CloudTrail account audit baseline
- CloudWatch logging baseline and platform alarms
- Secrets Manager placeholder structure
- Glue Catalog and lakehouse conventions
- CI/CD deployment foundation
- stable outputs for product repositories

## Product Responsibilities

Product repositories own workload-specific resources, lifecycle, and business behavior. Examples include:

- IoT Core resources
- EventBridge product rules
- Lambda functions
- Glue jobs, crawlers, workflows, databases, and product tables
- API Gateway APIs
- dbt projects and Streamlit applications
- product-specific CI/CD, secrets, alarms, dashboards, and business rules

## Boundary Examples

The platform creates the shared curated bucket and exports lakehouse conventions. Product repositories create product prefixes, Glue databases, and Iceberg tables in their own Terraform state.

The platform creates reusable deployment roles and a permission boundary. Product repositories deploy product resources using those guardrails.

The platform creates baseline log groups and audit trails. Product repositories create workload-specific observability for their own services.

## Expansion Rule

Add a component to this repository only when it is reusable across multiple products or required to operate the shared platform foundation. If a component exists for one business use case, it belongs in a product repository.

See [Architecture](architecture.md) for the detailed component model and [Product Onboarding](product-onboarding.md) for the product-facing interface.
