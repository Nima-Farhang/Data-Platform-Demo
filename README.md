# Data Platform Demo

## Overview

**Data Platform Demo** is a self-contained blueprint for bootstrapping a reusable AWS-based data platform foundation.

It is designed to support future data product repositories such as **Data Product Demo** by providing shared platform infrastructure, security boundaries, storage zones, deployment roles, and operational foundations.

This repository is intentionally focused on the **platform layer**, not business-specific data products.

---

## Purpose

Many small and mid-sized companies need a reliable data platform foundation before they can build useful analytics, reporting, automation, or AI-enabled data products.

This project demonstrates how to create that foundation using production-minded engineering patterns:

- Infrastructure as Code
- remote Terraform state
- repeatable environment deployment
- shared data lake storage
- IAM role separation
- logging and monitoring baseline
- CI/CD-ready structure
- clear platform/product boundary

---

## Relationship to Data Product Demo

This repository is designed to work alongside a separate data product repository.

```text
Data Platform Demo
        ↓
Creates shared platform infrastructure
        ↓
Data Product Demo
        ↓
Creates product-specific Snowflake, dbt, and Streamlit resources
```

### Data Platform Demo owns

- Terraform backend
- shared AWS platform foundation
- shared S3 buckets
- IAM roles and policies
- logging baseline
- secrets baseline
- CI/CD deployment role
- VPC networking baseline

### Data Product Demo owns

- product-specific Snowflake database
- product-specific Snowflake schemas
- product-specific warehouse
- dbt models
- Streamlit apps
- product-specific CI/CD
- product-specific business logic

The guiding rule is:

> Shared infrastructure belongs in the platform repo. Business-product infrastructure belongs in the product repo.

---

## Architecture at a Glance

```text
GitHub Repository
│
├── terraform/
│   ├── bootstrap/
│   │   └── Remote Terraform state backend
│   │
│   ├── modules/
│   │   ├── storage/
│   │   ├── iam/
│   │   ├── secrets/
│   │   ├── logging/
│   │   └── networking/
│   │
│   └── environments/
│       ├── dev/
│       ├── test/
│       └── prod/
│
├── docs/
│   └── Architecture, security, naming, and design decisions
│
├── scripts/
│   └── Helper scripts for bootstrap, plan, and apply
│
├── .github/workflows/
│   └── Terraform CI/CD workflows
│
└── .devcontainer/
    └── Reproducible development environment
```

---

## Core Infrastructure

The first version of this repository should build a minimal but professional platform foundation.

V1 is locked to shared platform infrastructure only. It includes only:

- Terraform remote state backend
- VPC networking baseline
- Shared platform S3 storage
- IAM roles
- Logging baseline
- Secrets Manager baseline
- CI/CD deployment role

V1 explicitly excludes Snowflake provisioning, dbt models, Streamlit apps, Kafka, Kubernetes, data pipelines, product-specific infrastructure, and business dashboards.

### 1. Terraform Backend

Creates:

- S3 bucket for Terraform state
- DynamoDB table for state locking
- bucket encryption
- bucket versioning
- public access block

### 2. Shared Data Lake Storage

Creates standard platform buckets such as:

- raw landing bucket
- artifacts bucket
- logs bucket

These are shared platform resources that future data products can use.

### 3. IAM Roles and Policies

Creates role patterns for:

- platform administration
- GitHub Actions / CI/CD deployment
- product deployment

### 4. Secrets Baseline

Creates a safe structure for future secret management using AWS Secrets Manager.

Secret values should not be committed to source control.

### 5. Logging Baseline

Creates baseline log groups and optional alerting structures for future platform workloads.

### 6. VPC Networking Baseline

Networking should be kept minimal in the first version.

V1 creates:

- VPC
- public subnet
- private subnets
- internet gateway

Future versions may add private endpoints, NAT Gateway, multi-AZ networking, security groups, and route tables where required.

---

## Recommended Repository Structure

```text
data-platform-demo/
│
├── README.md
├── QUICKSTART.md
├── DEVELOPMENT_GUIDE.md
├── commands.md
│
├── .devcontainer/
│   ├── Dockerfile
│   ├── devcontainer.json
│   └── setup.sh
│
├── .github/
│   └── workflows/
│       ├── terraform-ci.yml
│       └── terraform-apply-dev.yml
│
├── terraform/
│   ├── bootstrap/
│   ├── modules/
│   │   ├── storage/
│   │   ├── iam/
│   │   ├── secrets/
│   │   ├── logging/
│   │   └── networking/
│   │
│   ├── environments/
│   │   ├── dev/
│   │   ├── test/
│   │   └── prod/
│   │
│   └── examples/
│       └── product-integration/
│
├── docs/
│   ├── architecture.md
│   ├── platform-boundaries.md
│   ├── naming-and-tagging.md
│   ├── security-model.md
│   ├── future-roadmap.md
│   └── decisions/
│
└── scripts/
    ├── bootstrap_backend.sh
    ├── plan_dev.sh
    └── apply_dev.sh
```

---

## Development Sequence

Recommended build order:

1. Create repository skeleton and documentation.
2. Add Terraform bootstrap backend.
3. Add storage module.
4. Add IAM module.
5. Add logging module.
6. Add secrets module.
7. Compose the `dev` environment.
8. Add Terraform CI workflow.
9. Add documentation for platform/product integration.

Do not start with every possible cloud service. Keep version 1 small and reliable.

---

## What This Repository Should Not Do

This repository should not create:

- Snowflake provisioning
- dbt models
- Streamlit apps
- Kafka
- Kubernetes
- data pipelines
- product-specific infrastructure
- business dashboards

Those belong in the relevant data product repository.

---

## Example Platform Flow

```text
1. Bootstrap Terraform backend
2. Deploy shared platform infrastructure
3. Export platform outputs
4. Product repository consumes outputs
5. Product repository deploys business-specific infrastructure and workloads
```

---

## Intended Use Cases

This repository can be used as:

- a platform engineering portfolio project
- a reusable consulting/company delivery blueprint
- a reference implementation for small-company data platforms
- a foundation for future Snowflake, dbt, Streamlit, Glue, or Iceberg extensions

---

## Long-Term Vision

The long-term vision is to create a repeatable platform foundation that can support multiple product repositories.

Future extensions may include:

- Snowflake external volume integration
- AWS Glue ingestion framework
- Iceberg table support
- metadata/catalog integration
- cost monitoring
- data quality monitoring
- platform observability dashboards

---

## Design Principle

The central design principle is:

> Build the platform once, then allow many data products to be deployed on top of it.

This keeps the architecture clean, reusable, and easier to grow over time.
