# Data Platform Demo

Data Platform Demo is a self-contained AWS platform foundation for future data product repositories. It creates shared infrastructure, security guardrails, deployment roles, storage, logging, audit, and lakehouse conventions that product teams can reuse without placing product workloads in this repository.

The repository owns shared platform infrastructure only. Product-specific infrastructure, pipelines, dbt projects, Streamlit apps, dashboards, and business logic belong in separate data product repositories.

## What This Repository Provides

- Terraform remote state bootstrap resources
- reusable Terraform modules for platform concerns
- environment compositions for `dev`, `test`, and `prod`
- shared VPC networking baseline with optional VPC endpoints
- shared S3 buckets for raw, curated, logs, and artifacts data
- shared KMS, IAM, GitHub OIDC, and product deployment permission boundary
- Secrets Manager placeholder structure
- CloudWatch logging baseline and CloudTrail audit baseline
- Glue Catalog and lakehouse naming conventions
- GitHub Actions based Terraform validation and deployment workflows

## Platform Boundary

Data Platform Demo creates shared foundations that many products can consume. Data product repositories create workload-specific resources in their own Terraform state.

```text
Data Platform Demo
  -> shared AWS platform infrastructure and outputs
Data product repository
  -> product-owned infrastructure, data models, apps, and business logic
```

Examples that belong in product repositories:

- IoT Core resources
- EventBridge product rules
- Lambda functions
- Glue jobs, crawlers, workflows, databases, and product tables
- API Gateway APIs
- dbt projects
- Streamlit applications
- product-specific dashboards, alarms, and business rules

## Repository Layout

```text
.
|-- .github/workflows/        Terraform CI/CD workflows
|-- docs/                     Architecture, operating standards, and ADRs
|-- scripts/                  Bootstrap and deployment helpers
`-- terraform/
    |-- bootstrap/            Remote state bootstrap stack
    |-- environments/         dev, test, and prod compositions
    `-- modules/              Reusable platform modules
```

## Authoritative Documentation

- [Architecture](docs/architecture.md) is the detailed source of truth for the platform design, component ownership, dependencies, and product interface.
- [Platform Scope](docs/platform-scope.md) defines what belongs in this repository versus product repositories.
- [Module Boundaries](docs/module-boundaries.md) defines each Terraform module's responsibilities.
- [Security Model](docs/security-model.md) describes the security baseline and guardrails.
- [Product Onboarding](docs/product-onboarding.md) explains how product repositories consume platform outputs.
- [Standards](docs/standards.md) covers naming and tagging conventions.
- [ADRs](docs/adr/README.md) record durable architecture decisions.

## Deployment Flow

The expected platform deployment flow is:

```text
terraform fmt
terraform validate
terraform plan
manual approval
terraform apply
```

Bootstrap the remote state first, then deploy environment compositions. Product deployments should use product-owned CI/CD and stay within the platform-provided role and permission boundary.

## Design Principle

Build the shared platform once, expose stable outputs, and let product repositories deploy independently on top of it.
