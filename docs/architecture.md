# Architecture

## Purpose

Data Platform Demo is a reusable AWS-based foundation for shared platform infrastructure.

The V1 architecture is intentionally small. It creates the shared platform infrastructure needed before data product repositories add product-specific infrastructure.

## Design Goals

V1 must be:

- Simple
- Secure
- Low-cost
- Extensible
- Production-realistic

It should not be feature-rich. The platform should provide a stable foundation that can be expanded safely.

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
Shared Platform Infrastructure
```

## V1 Core Components

V1 includes only the following platform components:

1. Terraform remote state backend
2. VPC networking baseline
3. Shared platform S3 storage
4. IAM roles
5. Logging baseline
6. Secrets Manager baseline
7. CI/CD deployment role

## V1 Platform Scope (Locked)

The V1 platform scope is limited to the shared platform infrastructure needed before data product repositories are deployed.

V1 must include only:

- Terraform remote state backend
- VPC networking baseline
- Shared platform S3 storage
- IAM roles
- Logging baseline
- Secrets Manager baseline
- CI/CD deployment role

V1 must explicitly exclude:

- Snowflake provisioning
- dbt models
- Streamlit apps
- Kafka
- Kubernetes
- Data pipelines
- Product-specific infrastructure
- Business dashboards

Do not add new V1 technical components unless this architecture decision is updated.

## Platform vs Product Ownership

Data Platform Demo owns shared platform infrastructure. Data product repositories own product-specific infrastructure.

| Resource type | Owning repository |
| --- | --- |
| Terraform state backend | Data Platform Demo |
| Shared VPC | Data Platform Demo |
| Shared IAM roles | Data Platform Demo |
| Shared platform S3 buckets | Data Platform Demo |
| Logging baseline | Data Platform Demo |
| Secrets Manager baseline | Data Platform Demo |
| CI/CD deployment roles | Data Platform Demo |
| Product-specific S3 buckets | Data product repository |
| Product-specific Snowflake resources | Data product repository |
| dbt projects/models | Data product repository |
| Streamlit applications | Data product repository |
| Business pipelines | Data product repository |
| Product dashboards | Data product repository |
| Product-specific alerts | Data product repository |
| Business data contracts | Data product repository |

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

Networking provides the minimal AWS network boundary for V1.

It includes:

- VPC
- public subnet
- private subnet
- internet gateway

V1 does not include NAT Gateway, private endpoints, or multi-AZ complexity.

### Platform Storage

Storage provides shared platform S3 locations for data product repositories to consume.

It includes:

- `platform-raw`
- `platform-logs`
- `platform-artifacts`

Each bucket must use encryption, versioning, lifecycle rules, and public access blocking.

### IAM Roles

IAM provides role-based access for platform administration, deployment automation, and data product repository deployment.

It includes:

- Platform Admin Role
- CI/CD Deployment Role
- Product Deployment Role

IAM must follow least privilege and avoid hardcoded users.

### Logging Baseline

The logging baseline provides basic observability for platform resources.

It includes:

- CloudWatch Log Groups
- basic metric alarms

### Secrets Manager Baseline

The Secrets Manager baseline provides a safe structure for future credentials and tokens.

It includes AWS Secrets Manager placeholders only. Real credentials must not be committed to source control.

### Environment Wiring

Environment wiring composes the locked V1 components into deployable environments. It is deployment structure, not an additional platform component.

The platform supports:

- `dev`
- `test`
- `prod`

Each environment uses separate Terraform state, independent configuration, and shared modules.

## Dependency Flow

V1 must be built in this order:

```text
Bootstrap
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
Logging
      |
      v
Secrets
      |
      v
Environment Wiring
```

This order should not be violated.

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

## V1 Non-Goals

V1 does not include:

- Snowflake provisioning
- dbt models
- Streamlit apps
- Kafka
- Kubernetes
- data pipelines
- product-specific infrastructure
- business dashboards

Those belong to data product repositories or later post-V1 decisions.

## Completion Criteria

V1 is complete when:

- Terraform bootstrap works
- VPC deploys successfully
- storage buckets are created
- IAM roles are available
- logging is enabled
- secrets module is functional
- the `dev` environment deploys cleanly

Only after this should the platform move toward data product integration.
