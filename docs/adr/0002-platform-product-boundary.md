# 0002 — Platform and Product Boundary

## Status

Accepted

## Context

Data Platform Demo is intended to provide a reusable platform foundation for multiple future data product repositories.

Without a clear ownership boundary, the platform can easily absorb business-specific infrastructure, data models, pipelines, and application logic. That would make the platform harder to reuse and harder to operate consistently.

## Decision

Shared infrastructure belongs in the Data Platform Demo repository.

Business-product infrastructure belongs in the relevant data product repository.

Data Platform Demo owns:

- Terraform remote state backend
- shared AWS platform foundation
- minimal networking foundation
- shared S3 platform buckets
- IAM roles and policies
- logging and monitoring baseline
- secrets management structure
- CI/CD deployment foundation
- environment structure
- reusable outputs for product repositories

Data product repositories own:

- product-specific Snowflake databases
- product-specific Snowflake schemas
- product-specific warehouses
- product service users
- dbt projects
- Streamlit apps
- product-specific ingestion resources
- product-specific CI/CD
- business rules and data models

## Consequences

This keeps the platform reusable across multiple products.

Product repositories can move independently without changing shared platform foundations.

New resources should be added to this repository only when they are reusable across multiple products or required to operate the shared platform.

## Related Documents

- `docs/platform-scope.md`
- `docs/module-boundaries.md`
- `docs/architecture.md`
