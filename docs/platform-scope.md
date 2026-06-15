# Platform Scope

## Purpose

This document defines what the Data Platform Demo repository owns and what it deliberately leaves to data product repositories.

The guiding rule is:

> Shared infrastructure belongs in the platform repository. Business-product infrastructure belongs in the product repository.

## Platform Repository Responsibilities

Data Platform Demo owns shared AWS platform infrastructure that can support multiple future data products.

The current platform foundation includes:

- Terraform remote state backend
- environment structure for `dev`, `test`, and `prod`
- minimal VPC networking foundation
- optional VPC endpoints for private workloads
- shared S3 platform buckets for raw, logs, artifacts, and curated data
- platform KMS key
- IAM roles, GitHub OIDC support, and product deployment permission boundary
- CloudTrail account audit baseline
- CloudWatch logging and basic platform alarms
- AWS Secrets Manager placeholder structure
- Glue Catalog/lakehouse conventions for future Iceberg products
- CI/CD deployment foundation
- reusable outputs that product repositories consume

## Product Repository Responsibilities

Data product repositories own business-specific infrastructure, transformations, applications, and workloads.

Product repository responsibilities include:

- IoT Core resources
- EventBridge product rules
- Lambda functions
- Glue jobs
- API Gateway APIs
- product Glue databases
- product Iceberg tables and table definitions
- product-specific crawlers or ingestion resources
- dbt projects
- Streamlit apps
- product-specific CI/CD
- business rules, data models, and dashboards

## Platform In Scope

The platform repository may create shared resources when they are reusable across products or required to operate the shared foundation.

In scope examples:

- remote state and locking
- shared VPC, subnets, internet gateway, and optional endpoints
- shared platform S3 buckets and lifecycle controls
- reusable platform IAM roles and permission boundaries
- GitHub OIDC provider integration and CI/CD trust policies
- CloudTrail account-level audit trail
- platform CloudWatch log groups and platform-level alarms
- shared Secrets Manager naming structure
- platform KMS key and key policies for platform services
- Glue Catalog conventions and optional generic environment marker database

## Product Out of Scope

The platform repository must not create product-specific workload resources.

Out of scope examples:

- IoT Core topic rules, certificates, policies, or things
- EventBridge rules for a product workflow
- Lambda functions for ingestion or business logic
- Glue jobs, crawlers, triggers, or workflows for a product
- API Gateway APIs for product services
- product Glue databases or product Iceberg tables
- dbt models, tests, exposures, and project configuration
- Streamlit applications
- product dashboards and product-specific alerts

## Boundary Examples

The platform repository creates the shared curated bucket and exports the lakehouse root location. A product repository creates product-specific prefixes, Glue databases, and Iceberg tables beneath that location.

The platform repository creates reusable deployment roles and permission boundaries. A product repository attaches or assumes those roles to deploy its own product resources.

The platform repository creates platform-level log groups and exposes the product log base. A product repository creates workload-specific logs, metrics, and alarms for its own Lambda, Glue, API Gateway, IoT, or application resources.

## Product Onboarding

Product repositories should consume platform outputs instead of hardcoding shared infrastructure names.

The full product onboarding guide is maintained in `docs/product-onboarding.md`. It explains how product repositories should read platform outputs, configure deployment roles and permission boundaries, use shared storage and lakehouse conventions, and create product-owned resources in their own Terraform state.

Key output groups include:

- environment and network outputs
- shared storage outputs
- KMS and IAM outputs
- logging and secrets outputs
- CloudTrail audit outputs
- lakehouse and Glue Catalog convention outputs

Product repositories should use these outputs to create product-owned resources with product-specific names, tags, IAM policies, and lifecycle choices.

## Expansion Rule

New components should be added to the platform only when they are reusable across multiple products or required to operate the shared foundation.

If a component exists for one business use case, it belongs outside this repository.
