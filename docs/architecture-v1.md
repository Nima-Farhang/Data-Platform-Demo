
# Architecture V1 — Data Platform Demo

## Purpose

This document defines the **minimal viable platform architecture (V1)** for the Data Platform Demo repository.

This is not the final architecture.

This is the **first stable foundation** that:

- Can be deployed safely
- Can be extended later
- Remains cost-efficient
- Supports multiple future data products

---

# Design Goals

V1 architecture must be:

- Simple
- Secure
- Low-cost
- Extensible
- Production-realistic

Not feature-rich.

---

# Platform Boundary Definition

This platform builds **shared infrastructure only**.

It does NOT build:

- Data pipelines
- dbt models
- Streamlit apps
- Product-specific storage
- Snowflake databases
- Business logic

Those belong in:

**Data Product repositories**

---

# High-Level Architecture

```
                GitHub Repository
                         │
                         │
                 GitHub Actions
                         │
                         ▼
               Terraform Deployment
                         │
                         ▼
                AWS Platform Account
                         │
 ┌─────────────────────────────────────────────┐
 │                                             │
 │              Core Infrastructure            │
 │                                             │
 │   ┌──────────────┐                          │
 │   │ Terraform    │                          │
 │   │ State Bucket │                          │
 │   └──────────────┘                          │
 │                                             │
 │   ┌──────────────┐                          │
 │   │ DynamoDB     │                          │
 │   │ Lock Table   │                          │
 │   └──────────────┘                          │
 │                                             │
 │   ┌──────────────┐                          │
 │   │ VPC          │                          │
 │   │ Networking   │                          │
 │   └──────────────┘                          │
 │                                             │
 │   ┌──────────────┐                          │
 │   │ Platform S3  │                          │
 │   │ Buckets      │                          │
 │   └──────────────┘                          │
 │                                             │
 │   ┌──────────────┐                          │
 │   │ IAM Roles    │                          │
 │   └──────────────┘                          │
 │                                             │
 │   ┌──────────────┐                          │
 │   │ CloudWatch   │                          │
 │   │ Logging      │                          │
 │   └──────────────┘                          │
 │                                             │
 │   ┌──────────────┐                          │
 │   │ Secrets      │                          │
 │   │ Manager      │                          │
 │   └──────────────┘                          │
 │                                             │
 └─────────────────────────────────────────────┘
```

---

# Core Components

## 1. Terraform Remote State

### Resources

- S3 Bucket
- DynamoDB Table

### Purpose

Provides:

- State storage
- State locking
- Version history

### Requirements

- Encryption enabled
- Versioning enabled
- Public access blocked

---

## 2. Networking (VPC)

### Resources

- VPC
- Public Subnet
- Private Subnet
- Internet Gateway

### Purpose

Creates:

- Network boundary
- Resource isolation
- Secure deployment base

### V1 Constraints

Do NOT include:

- NAT Gateway (unless required)
- Multi-AZ complexity
- Private endpoints

Keep minimal.

---

## 3. Platform Storage

### Resources

Three S3 buckets:

```
platform-raw
platform-logs
platform-artifacts
```

### Purpose

Supports:

- Data landing zones
- Platform logs
- Build artifacts

### Requirements

- Encryption enabled
- Versioning enabled
- Lifecycle rules configured

---

## 4. Identity and Access Management

### Roles

Create:

- Platform Admin Role
- CI/CD Deployment Role
- Product Deployment Role

### Principles

- Least privilege
- No wildcard permissions
- No hardcoded users

---

## 5. Logging and Monitoring

### Resources

- CloudWatch Log Groups
- Basic Metric Alarms

### Purpose

Provides:

- Platform observability
- Failure detection
- Troubleshooting support

---

## 6. Secrets Management

### Resources

- AWS Secrets Manager

### Purpose

Stores:

- API keys
- Tokens
- Credentials

### Rules

- No real credentials stored in Git
- Only placeholder values

---

# Environment Strategy

Platform supports:

```
dev
test
prod
```

Each environment:

- Uses separate Terraform state
- Has independent configuration
- Uses shared modules

---

# Naming Convention

All resources follow:

```
<project>-<environment>-<component>
```

Example:

```
data-platform-dev-vpc
data-platform-prod-logs
```

---

# Tagging Strategy

Every resource includes:

```
Project
Environment
Owner
CostCenter
ManagedBy
```

Purpose:

- Cost tracking
- Resource auditing
- Governance alignment

---

# Security Model

V1 Security includes:

- Encryption enabled everywhere
- IAM role-based access
- No public storage
- No exposed secrets

Future versions may add:

- KMS customization
- Private endpoints
- Network ACL rules

---

# CI/CD Integration

Platform integrates with:

GitHub Actions

Deployment flow:

```
Code Commit
        │
        ▼
terraform fmt
terraform validate
terraform plan
        │
Manual Approval
        │
terraform apply
```

---

# Dependency Flow

```
Bootstrap
      ↓
Networking
      ↓
Storage
      ↓
IAM
      ↓
Logging
      ↓
Secrets
      ↓
Environment Wiring
```

Never violate this order.

---

# V1 Non-Goals

V1 intentionally avoids:

- Snowflake provisioning
- Kafka infrastructure
- Kubernetes clusters
- Data warehouse configuration
- Streaming platforms

These belong in later phases.

---

# Future Expansion Path

V2 may introduce:

- Data Warehouse Module
- Streaming Platform
- Metadata Services
- Data Catalog
- Cost Monitoring

V3 may introduce:

- Multi-account deployment
- Private networking
- Advanced security layers

---

# Acceptance Criteria

V1 platform is complete when:

- Terraform bootstrap works
- VPC deploys successfully
- Storage buckets created
- IAM roles available
- Logging enabled
- Secrets module functional
- Dev environment deploys cleanly

Only then move to:

Data Product integration.

---

# Architectural Principle

This platform follows:

**Build Small → Expand Safely → Standardize Always**

Not:

**Build Big → Fix Later**
