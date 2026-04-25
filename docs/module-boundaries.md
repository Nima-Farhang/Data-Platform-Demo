# Module Boundaries

## Purpose

Module boundaries define what each Terraform module is responsible for when infrastructure code is added later.

This document describes boundaries only. It does not define or generate infrastructure code.

## Boundary Principles

Modules should be:

- focused on one platform concern
- reusable across environments
- independent where practical
- explicit about inputs and outputs
- free of business-specific assumptions

Environment compositions should wire modules together. Modules should not own environment orchestration.

## Bootstrap Boundary

The bootstrap layer owns Terraform remote state resources.

It is responsible for:

- S3 state bucket
- DynamoDB lock table
- state bucket encryption
- state bucket versioning
- state bucket public access block

It should not depend on the normal remote state backend because it creates that backend.

## Networking Module Boundary

The networking module owns the minimal V1 network foundation.

It is responsible for:

- VPC
- public subnet
- private subnet
- internet gateway

It should not create NAT Gateway, private endpoints, multi-AZ topology, or advanced network controls in V1 unless the architecture scope changes.

## Storage Module Boundary

The storage module owns shared platform S3 buckets.

It is responsible for:

- `platform-raw`
- `platform-logs`
- `platform-artifacts`
- bucket encryption
- bucket versioning
- lifecycle rules
- public access blocking

It should not create product-specific buckets or product-specific data layouts.

## IAM Module Boundary

The IAM module owns shared platform role patterns.

It is responsible for:

- Platform Admin Role
- CI/CD Deployment Role
- Product Deployment Role
- least-privilege role policies
- role trust relationships

It should not create hardcoded personal users or product-specific service users.

## Logging Module Boundary

The logging module owns the baseline observability resources.

It is responsible for:

- CloudWatch Log Groups
- basic metric alarms

It should not create advanced observability dashboards or product-specific monitoring in V1.

## Secrets Module Boundary

The secrets module owns the shared secrets structure.

It is responsible for:

- AWS Secrets Manager placeholder resources
- naming structure for future secrets
- tags and access boundaries for secrets

It should not store real credentials in Git or define product-specific secret values.

## Environment Composition Boundary

Environment folders wire shared modules into deployable stacks.

They are responsible for:

- selecting environment-specific configuration
- passing common tags
- passing naming inputs
- connecting module outputs where needed
- keeping state separate per environment

Environment compositions should not contain reusable module internals.

## Output Boundary

Modules should expose only outputs that downstream modules or product repositories need.

Examples include:

- VPC identifiers
- subnet identifiers
- shared bucket names
- IAM role ARNs
- log group names
- secret identifiers

Outputs should avoid exposing unnecessary implementation details.

## Product Boundary

Modules in this repository must not create:

- dbt models
- Streamlit apps
- Snowflake databases
- product-specific schemas
- product-specific warehouses
- product-specific pipelines
- business-specific resources

Those belong in data product repositories.
