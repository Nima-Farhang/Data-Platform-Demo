# Platform Scope

## Purpose

This document defines what the Data Platform Demo repository owns and what it deliberately leaves to data product repositories.

The guiding rule is:

> Shared infrastructure belongs in the platform repository. Business-product infrastructure belongs in the product repository.

## Platform Repository Responsibilities

Data Platform Demo owns shared platform infrastructure that can support multiple future data products.

V1 platform responsibilities are:

- Terraform remote state backend
- shared AWS platform foundation
- minimal networking foundation
- shared S3 platform buckets
- IAM roles and policies
- logging and monitoring baseline
- secrets management structure
- CI/CD deployment foundation
- environment structure for `dev`, `test`, and `prod`
- outputs that product repositories can consume later

## Data Product Repository Responsibilities

Data product repositories own business-specific infrastructure, transformations, applications, and workloads.

Product repository responsibilities include:

- product-specific Snowflake databases
- product-specific Snowflake schemas
- product-specific warehouses
- product-specific resource monitors
- product service users
- dbt projects
- Streamlit apps
- product-specific CI/CD
- product-specific ingestion resources
- business rules and data models

## V1 In Scope

V1 includes:

- Terraform remote state
- VPC networking
- platform S3 storage
- platform IAM roles
- CloudWatch logging and basic alarms
- AWS Secrets Manager placeholders
- environment wiring

## V1 Out of Scope

V1 does not include:

- data pipelines
- dbt models
- Streamlit apps
- product-specific storage
- Snowflake databases
- business logic
- Kafka infrastructure
- Kubernetes clusters
- streaming platforms
- data warehouse configuration

## Boundary Examples

The platform repository should create a shared artifacts bucket. A product repository should create or request only the product-specific prefixes or access it needs.

The platform repository should create reusable deployment roles. A product repository should use those roles to deploy its own product resources.

The platform repository should provide a secrets structure. A product repository should define the product-specific secrets it requires without committing real values.

## Expansion Rule

New components should be added to the platform only when they are reusable across multiple products or required to operate the shared foundation.

If a component exists for one business use case, it belongs outside this repository.
