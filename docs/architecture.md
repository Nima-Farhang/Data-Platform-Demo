# Architecture

## Purpose

Data Platform Demo is a reusable AWS-based platform foundation for future data product repositories.

The V1 architecture is intentionally small. It creates the shared platform services needed before product teams add Snowflake, dbt, Streamlit, ingestion, or business-specific workloads.

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

1. Terraform remote state
2. Networking
3. Platform storage
4. Identity and access management
5. Logging and monitoring
6. Secrets management
7. Environment wiring

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

V1 does not include NAT Gateway, private endpoints, or multi-AZ complexity unless a later requirement makes them necessary.

### Platform Storage

Storage provides shared S3 locations for future platform and product use.

It includes:

- `platform-raw`
- `platform-logs`
- `platform-artifacts`

Each bucket must use encryption, versioning, lifecycle rules, and public access blocking.

### Identity and Access Management

IAM provides role-based access for platform administration, deployment automation, and future product deployment.

It includes:

- Platform Admin Role
- CI/CD Deployment Role
- Product Deployment Role

IAM must follow least privilege and avoid hardcoded users.

### Logging and Monitoring

Logging and monitoring provide baseline observability for platform resources.

It includes:

- CloudWatch Log Groups
- basic metric alarms

### Secrets Management

Secrets management provides a safe structure for future credentials and tokens.

It includes AWS Secrets Manager placeholders only. Real credentials must not be committed to source control.

### Environment Wiring

Environment wiring composes shared modules into deployable environments.

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
- Kafka infrastructure
- Kubernetes clusters
- data warehouse configuration
- streaming platforms
- data pipelines
- dbt models
- Streamlit apps
- product-specific storage
- business logic

Those belong to later platform phases or separate data product repositories.

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
