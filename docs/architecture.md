# Architecture

## Purpose

Data Platform Demo is a reusable AWS-based foundation for shared platform infrastructure.

The architecture provides the shared resources, conventions, and outputs that future data product repositories can build on without placing product workloads in this repository.

## Design Goals

The platform must be:

- simple
- secure
- low-cost by default
- extensible
- production-realistic
- clear about platform versus product ownership

## High-Level Flow

```text
GitHub Repository
        |
        v
GitHub Actions
        |
        v
Terraform Deployment
        |
        v
AWS Platform Account
        |
        v
Shared Platform Foundation
        |
        v
Product Repositories Consume Outputs
```

## Core Components

The platform foundation includes:

1. Terraform remote state backend
2. VPC networking baseline
3. Optional VPC endpoints
4. Shared platform S3 storage
5. Platform KMS key
6. IAM roles, GitHub OIDC, and product permission boundary
7. Secrets Manager baseline
8. CloudWatch logging baseline
9. CloudTrail audit baseline
10. Glue Catalog/lakehouse conventions
11. Environment wiring and reusable outputs

## Platform vs Product Ownership

Data Platform Demo owns shared platform infrastructure. Data product repositories own product-specific infrastructure.

| Resource type | Owning repository |
| --- | --- |
| Terraform state backend | Data Platform Demo |
| Shared VPC, subnets, and optional VPC endpoints | Data Platform Demo |
| Shared platform S3 buckets | Data Platform Demo |
| Platform KMS key | Data Platform Demo |
| Shared IAM roles and product permission boundary | Data Platform Demo |
| GitHub OIDC provider and CI/CD trust policy | Data Platform Demo |
| Secrets Manager placeholder structure | Data Platform Demo |
| Platform CloudWatch log groups and platform alarms | Data Platform Demo |
| Account-level CloudTrail trail | Data Platform Demo |
| Glue Catalog conventions and platform marker database | Data Platform Demo |
| IoT Core product resources | Data product repository |
| EventBridge product rules | Data product repository |
| Lambda functions | Data product repository |
| Glue jobs, crawlers, and product workflows | Data product repository |
| API Gateway APIs | Data product repository |
| Product Glue databases and Iceberg tables | Data product repository |
| dbt projects/models | Data product repository |
| Streamlit applications | Data product repository |
| Product-specific alerts and dashboards | Data product repository |
| Business data contracts and models | Data product repository |

## Component Summary

### Terraform Remote State

The Terraform backend stores state remotely and supports safe collaboration.

It includes:

- S3 bucket for Terraform state
- DynamoDB table for state locking
- bucket encryption
- bucket versioning
- public access block

### Networking

Networking provides the AWS network boundary.

It includes:

- VPC
- public subnet
- private subnet
- internet gateway
- optional VPC endpoints for S3, CloudWatch Logs, Secrets Manager, STS, Glue, and KMS

VPC endpoints are disabled by default. The platform does not create NAT Gateway, transit networking, or multi-AZ topology unless the architecture scope changes.

### Platform Storage

Storage provides shared platform S3 locations for platform and product repositories to consume.

It includes:

- raw bucket
- logs bucket
- artifacts bucket
- curated bucket

Each bucket uses encryption, versioning, lifecycle rules, and public access blocking.

### KMS

KMS provides the shared platform key and alias.

The key is used by shared platform resources such as S3, CloudTrail, and CloudWatch Logs where configured.

### IAM

IAM provides role-based access for platform administration, deployment automation, and data product repository deployment.

It includes:

- Platform Admin Role
- CI/CD Deployment Role
- Product Deployment Role
- GitHub OIDC integration
- product deployment permission boundary

IAM must follow least privilege and avoid hardcoded users.

### Secrets Manager Baseline

The Secrets Manager baseline provides a safe structure for future credentials and tokens.

It includes AWS Secrets Manager placeholders only. Real credentials must not be committed to source control.

### Logging Baseline

The logging baseline provides basic observability for platform resources.

It includes:

- platform runtime log group
- platform deployment log group
- product log base group
- basic platform error-count metric alarms
- deployment failure placeholder alarm

It does not include product-specific workload alarms.

### Audit Baseline

The audit baseline provides account-level CloudTrail logging for each environment/account.

It includes:

- CloudTrail trail
- log file validation
- delivery to the platform logs bucket
- CloudTrail log prefix outputs

It does not create product-specific trails.

### Lakehouse Catalog Foundation

The lakehouse module defines shared Glue Catalog conventions for future Iceberg-based products.

It includes:

- Glue catalog ID output
- curated bucket location output
- product database naming pattern
- product Iceberg table location pattern
- optional generic platform Glue database marker

It does not create product Glue databases, product tables, crawlers, Glue jobs, or Iceberg definitions.

### Environment Wiring

Environment wiring composes modules into deployable environments.

The platform supports:

- `dev`
- `test`
- `prod`

Each environment uses separate Terraform state, independent configuration, and shared modules.

## Dependency Flow

The platform foundation is composed in this order:

```text
Bootstrap
      |
      v
KMS
      |
      v
Networking
      |
      v
Storage
      |
      v
IAM
      |
      v
Secrets / Logging / Audit / Lakehouse
      |
      v
Environment Outputs
```

Some modules can be applied together once their inputs are available, but dependencies should remain explicit through Terraform module inputs and outputs.

## Product Onboarding

A product repository should consume platform outputs and create product-owned resources in its own Terraform state.

The detailed onboarding workflow is documented in `docs/product-onboarding.md`.

At a high level, product repositories consume outputs for:

- environment and network placement
- shared storage locations
- platform KMS key usage
- product deployment roles and permission boundaries
- logging and secrets conventions
- CloudTrail audit context
- Glue Catalog and lakehouse naming conventions

The product repository then owns its IoT Core resources, EventBridge rules, Lambda functions, Glue jobs, API Gateway APIs, product Glue databases, product Iceberg tables, dbt project, Streamlit app, and product alarms.

## CI/CD Flow

The platform is designed to integrate with GitHub Actions.

The expected deployment flow is:

```text
Code Commit
      |
      v
terraform fmt
      |
      v
terraform validate
      |
      v
terraform plan
      |
      v
Manual Approval
      |
      v
terraform apply
```

Product CI/CD should live in product repositories and use the exported platform roles and boundaries.

## Non-Goals

The platform does not include:

- IoT Core product resources
- EventBridge product rules
- Lambda functions
- Glue jobs or crawlers
- API Gateway product APIs
- product Iceberg tables
- dbt projects
- Streamlit apps
- product-specific infrastructure
- business dashboards

Those belong to data product repositories.
