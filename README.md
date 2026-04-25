# Data Platform Demo

## Overview

**Data Platform Demo** is a self-contained blueprint for bootstrapping reusable AWS-based shared platform infrastructure.

It is designed to support future data product repositories by providing shared platform infrastructure, security boundaries, storage zones, deployment roles, and operational foundations.

This repository is intentionally focused on **shared platform infrastructure**, not product-specific infrastructure.

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

## Relationship to Data Product Repositories

Data Platform Demo is designed to work alongside a separate data product repository.

```text
Data Platform Demo
        ↓
Creates shared platform infrastructure
        ↓
Data product repository
        ↓
Creates product-specific infrastructure
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

### Data product repository owns

- product-specific Snowflake resources
- dbt models
- Streamlit apps
- product-specific CI/CD
- product-specific business logic

The guiding rule is:

> Shared platform infrastructure belongs in Data Platform Demo. Product-specific infrastructure belongs in the data product repository.

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

The first version of this repository should build a minimal but professional shared platform infrastructure foundation.

The V1 platform scope is locked to shared platform infrastructure only. It includes only:

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

These are shared platform infrastructure resources that future data product repositories can use.

### 3. IAM Roles and Policies

Creates role patterns for:

- platform administration
- GitHub Actions / CI/CD deployment
- product deployment

### 4. Secrets Baseline

Creates a safe structure for future secret management using AWS Secrets Manager.

Secret values should not be committed to source control.

### 5. Logging Baseline

Creates baseline log groups and optional alerting structures for shared platform infrastructure.

### 6. VPC Networking Baseline

Networking should be kept minimal in the first version.

V1 creates:

- VPC
- public subnet
- private subnets
- internet gateway

Post-V1 versions may expand the networking baseline only when a clear product or platform requirement exists.

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
4. Data product repository consumes outputs
5. Data product repository deploys product-specific infrastructure
```

---

## Future Expansion (Post-V1)

Post-V1 work may add integrations around the deployed platform foundation.

Those additions should be documented in a later architecture decision before any new technical components are introduced.

---

## Design Principle

The central design principle is:

> Build the platform once, then allow many data products to be deployed on top of it.

This keeps the architecture clean, reusable, and easier to grow over time.
