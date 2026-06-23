# Module Boundaries

Module boundaries define what each Terraform module owns and what remains in environment composition or product repositories.

## Principles

Modules should be focused, reusable across environments, explicit about inputs and outputs, and free of product-specific assumptions. Environment compositions wire modules together; modules should not own environment orchestration.

## Bootstrap

Owns Terraform remote state resources:

- S3 state bucket
- DynamoDB lock table
- state bucket encryption, versioning, and public access block

Bootstrap creates the backend and should not depend on that backend.

## Networking

Owns the platform network foundation:

- VPC
- public and private subnets
- internet gateway
- optional VPC endpoints for S3, CloudWatch Logs, Secrets Manager, STS, Glue, and KMS
- endpoint outputs

VPC endpoints are optional and disabled by default. NAT Gateway, transit networking, multi-AZ expansion, and advanced network controls require an explicit scope change.

## Storage

Owns shared platform S3 buckets:

- raw
- curated
- logs
- artifacts
- encryption, versioning, lifecycle rules, and public access blocking

The module must not manage product-specific buckets, prefixes, or data layouts.

## KMS

Owns the shared platform KMS key, alias, rotation setting, and key policy statements required by shared platform services.

Product-specific keys require a deliberate reusable platform pattern before being added here.

## IAM

Owns shared platform identity patterns:

- Platform Admin Role
- CI/CD Deployment Role
- Product Deployment Role
- GitHub OIDC provider integration when enabled
- product deployment permission boundary
- least-privilege policies and trust relationships

The module must not create hardcoded personal users, product service users, product Lambda roles, or workload-specific IAM policies.

## Secrets

Owns placeholder Secrets Manager resources, naming structure, tags, and access boundaries. Real credentials and product-specific secret values belong outside this repository.

## Logging

Owns reusable CloudWatch platform logging:

- platform log groups
- deployment log groups
- product log base group
- retention configuration
- generic platform metric filters and alarms

Product workload alarms belong in product repositories.

## Audit

Owns the account-level CloudTrail baseline, log file validation, delivery to the platform logs bucket, bucket policy for the configured prefix, and audit outputs.

## Lakehouse

Owns Glue Catalog and lakehouse conventions:

- catalog ID output
- curated bucket location output
- product database naming pattern
- product table location pattern
- optional generic platform database marker

Product Glue databases, tables, crawlers, jobs, and Iceberg definitions belong in product repositories.

## Environment Composition

Environment folders and root composition select configuration, pass common tags, connect module outputs, and keep state separate per environment.

## Output Boundary

Expose outputs that downstream modules or product repositories need, such as VPC IDs, bucket names and ARNs, KMS key ARN, role ARNs, permission boundary ARN, log group names, CloudTrail details, and lakehouse conventions. Avoid exposing internal implementation details.

See [Platform Scope](platform-scope.md) for repository ownership rules.
