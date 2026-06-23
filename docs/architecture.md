# Architecture

Data Platform Demo is a reusable AWS foundation for shared platform infrastructure. It provides common resources, security guardrails, conventions, and outputs that product repositories can consume while keeping product workloads outside this repository.

## Design Goals

The platform is designed to be simple, secure, low-cost by default, extensible, production-realistic, and explicit about platform versus product ownership.

## High-Level Flow

```text
GitHub repository
  -> GitHub Actions
  -> Terraform deployment
  -> AWS platform account
  -> shared platform foundation
  -> product repositories consume outputs
```

## Component Model

The platform foundation includes:

1. Terraform remote state backend
2. VPC networking baseline and optional VPC endpoints
3. shared S3 storage for raw, curated, logs, and artifacts data
4. platform KMS key
5. IAM roles, GitHub OIDC, and product deployment permission boundary
6. Secrets Manager placeholder structure
7. CloudWatch logging baseline
8. CloudTrail audit baseline
9. Glue Catalog and lakehouse conventions
10. environment wiring and reusable outputs

## Ownership Boundary

Data Platform Demo owns shared platform infrastructure. Product repositories own workload-specific infrastructure, data models, applications, and business behavior.

| Platform owns | Product repositories own |
| --- | --- |
| Terraform state backend | product Terraform state |
| VPC, subnets, and optional endpoints | product network placement choices within approved boundaries |
| shared S3 buckets | product prefixes, objects, and data layouts |
| platform KMS key | product-specific key patterns when required and approved |
| shared IAM roles and permission boundary | product workload roles and policies within the boundary |
| GitHub OIDC provider and platform CI/CD trust | product CI/CD workflows |
| Secrets Manager placeholder structure | product secret values and rotations |
| platform log groups and platform alarms | product dashboards, metrics, and alarms |
| account-level CloudTrail trail | product audit documentation and evidence |
| Glue Catalog conventions and optional marker database | product Glue databases, Iceberg tables, crawlers, and jobs |

Product repositories also own IoT Core resources, EventBridge rules, Lambda functions, API Gateway APIs, dbt projects, Streamlit applications, and business rules.

## Components

### Terraform Remote State

The bootstrap stack creates the S3 state bucket and DynamoDB lock table. State storage is encrypted, versioned, and blocked from public access.

### Networking

The networking module creates the VPC, public subnet, private subnet, and internet gateway. Optional endpoints can be enabled for S3, CloudWatch Logs, Secrets Manager, STS, Glue, and KMS.

VPC endpoints are disabled by default because interface endpoints add cost. NAT Gateway, transit networking, multi-AZ expansion, and advanced network controls are outside the default baseline.

### Storage

The storage module creates shared raw, curated, logs, and artifacts buckets. Buckets use encryption, versioning, lifecycle rules, and public access blocking.

Product repositories may use shared bucket outputs but must manage their own product prefixes and data layouts.

### KMS

The KMS module creates the shared platform key and alias. Shared platform resources such as S3, CloudTrail, and CloudWatch Logs can use the key where configured.

### IAM and GitHub OIDC

The IAM module provides:

- Platform Admin Role
- CI/CD Deployment Role
- Product Deployment Role
- GitHub OIDC integration
- product deployment permission boundary

Platform roles manage shared platform resources. Product deployment must stay inside the exported permission boundary and must not administer platform IAM, CloudTrail, shared buckets, or platform KMS policies.

### Secrets

The secrets module creates placeholder structure and naming conventions in AWS Secrets Manager. Real credentials must not be committed to Git and product secret values belong to product repositories.

### Logging

The logging module creates platform log groups, deployment log groups, a product log base group, retention configuration, and generic platform alarms. Product workload observability remains product-owned.

### Audit

The audit module creates account-level CloudTrail logging for each environment/account, enables log file validation, and delivers logs to the platform logs bucket under a controlled prefix.

### Lakehouse Catalog

The lakehouse module defines Glue Catalog and Iceberg conventions for future products. It can expose catalog IDs, curated bucket locations, database name patterns, table location patterns, and an optional generic platform marker database.

It does not create product Glue databases, product Iceberg tables, crawlers, Glue jobs, or business data models.

### Environment Wiring

The repository supports `dev`, `test`, and `prod`. Each environment uses separate Terraform state, independent configuration, and the same reusable modules.

## Dependency Flow

```text
Bootstrap
  -> KMS
  -> Networking
  -> Storage
  -> IAM
  -> Secrets / Logging / Audit / Lakehouse
  -> Environment outputs
```

Terraform module inputs and outputs should make these dependencies explicit.

## Product Interface

Product repositories should consume platform outputs instead of hardcoding shared infrastructure names.

Important output groups include:

- environment and network: `aws_region`, `environment`, `vpc_id`, subnet IDs, endpoint IDs
- storage: shared bucket names and ARNs for raw, curated, logs, and artifacts
- encryption and IAM: `platform_kms_key_arn`, deployment role ARNs, permission boundary ARN
- logging and secrets: log group names and ARNs, secret placeholder identifiers
- audit: CloudTrail trail and log location outputs
- lakehouse: catalog ID, curated bucket location, database pattern, table location pattern

See [Product Onboarding](product-onboarding.md) for the product repository workflow.

## CI/CD Flow

The platform deployment model is:

```text
Code commit
  -> terraform fmt
  -> terraform validate
  -> terraform plan
  -> manual approval
  -> terraform apply
```

Product CI/CD lives in product repositories and uses the platform-provided roles, outputs, and permission boundary.

## Non-Goals

The platform does not create product workloads, business logic, product databases or tables, pipelines, applications, dashboards, or product-specific alarms. Those belong to product repositories.
