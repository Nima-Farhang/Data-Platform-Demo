# Module Boundaries

## Purpose

Module boundaries define what each Terraform module owns and what it must leave to environment composition or product repositories.

## Boundary Principles

Modules should be:

- focused on one platform concern
- reusable across environments
- independent where practical
- explicit about inputs and outputs
- free of product-specific assumptions

Environment compositions wire modules together. Modules should not own environment orchestration.

## Current Platform Modules

The platform foundation includes these reusable module boundaries:

- `networking`
- `storage`
- `kms`
- `iam`
- `secrets`
- `logging`
- `audit`
- `lakehouse`

## Bootstrap Boundary

The bootstrap layer owns Terraform remote state resources.

It is responsible for:

- S3 state bucket
- DynamoDB lock table
- state bucket encryption
- state bucket versioning
- state bucket public access block

It should not depend on the normal remote state backend because it creates that backend.

## Networking Module Boundary

The networking module owns the platform network foundation.

It is responsible for:

- VPC
- public subnet
- private subnet
- internet gateway
- optional VPC endpoints for S3, CloudWatch Logs, Secrets Manager, STS, Glue, and KMS
- endpoint IDs as outputs

VPC endpoints are optional and disabled by default because interface endpoints add cost. The module must not create NAT Gateway, multi-AZ topology, transit networking, or advanced network controls unless explicitly added to the platform scope.

## Storage Module Boundary

The storage module owns shared platform S3 buckets.

It is responsible for:

- raw bucket
- logs bucket
- artifacts bucket
- curated bucket
- bucket encryption
- bucket versioning
- lifecycle rules
- public access blocking

It should not create product-specific buckets, product-specific data layouts, or product-owned prefixes as managed resources.

## KMS Module Boundary

The KMS module owns the shared platform KMS key.

It is responsible for:

- platform KMS key
- key alias
- key rotation
- key policy statements required by shared platform services such as CloudTrail and CloudWatch Logs

It should not create product-specific keys unless the platform intentionally defines a reusable product key pattern.

## IAM Module Boundary

The IAM module owns shared platform role patterns.

It is responsible for:

- Platform Admin Role
- CI/CD Deployment Role
- Product Deployment Role
- GitHub OIDC provider integration when enabled
- product deployment permission boundary
- least-privilege role policies
- role trust relationships

It should not create hardcoded personal users, product-specific service users, product Lambda roles, or product workload IAM policies.

## Secrets Module Boundary

The secrets module owns the shared secrets structure.

It is responsible for:

- AWS Secrets Manager placeholder resources
- naming structure for future secrets
- tags and access boundaries for secrets

It should not store real credentials in Git or define product-specific secret values.

## Logging Module Boundary

The logging module owns the reusable platform CloudWatch logging baseline.

It is responsible for:

- platform log group
- deployment log group
- product log base group
- retention variables
- generic platform error-count metric filters
- deployment failure placeholder alarm

It should not create product-specific Lambda, Glue, API Gateway, IoT, or application alarms.

## Audit Module Boundary

The audit module owns the account-level CloudTrail baseline for an environment/account.

It is responsible for:

- account-level CloudTrail trail
- CloudTrail log file validation
- CloudTrail delivery to the platform logs bucket
- CloudTrail bucket policy for the configured log prefix
- trail and log location outputs

It should not create product-specific audit trails.

## Lakehouse Module Boundary

The lakehouse module owns shared Glue Catalog conventions for future Iceberg products.

It is responsible for:

- catalog ID output
- curated bucket location output
- product database naming convention output
- product Iceberg table location convention output
- optional generic platform Glue database marker

It must not create product-specific Glue databases, Glue tables, crawlers, Glue jobs, or Iceberg table definitions.

## Environment Composition Boundary

Environment folders and the root composition wire shared modules into deployable stacks.

They are responsible for:

- selecting environment-specific configuration
- passing common tags
- passing naming inputs
- connecting module outputs where needed
- keeping state separate per environment

Environment compositions should not contain reusable module internals.

## Output Boundary

Modules should expose only outputs that downstream modules or data product repositories need.

Examples include:

- VPC and subnet identifiers
- VPC endpoint IDs
- shared bucket names and ARNs
- KMS key ARN
- IAM role ARNs
- permission boundary policy ARN
- log group names and ARNs
- secret identifiers
- CloudTrail trail and log location
- Glue Catalog ID and lakehouse naming conventions

Outputs should avoid exposing unnecessary implementation details.

## Product Boundary

Modules in this repository must not create:

- IoT Core product resources
- EventBridge product rules
- Lambda functions
- Glue jobs, crawlers, or product workflows
- API Gateway product APIs
- product Glue databases
- product Iceberg tables
- dbt projects
- Streamlit apps
- product-specific infrastructure
- business dashboards

Those belong in data product repositories.
