# Security Model

## Purpose

The security model provides a practical baseline for a small, production-minded AWS data platform foundation.

The goal is to reduce avoidable risk while keeping the platform reusable and understandable.

## Security Principles

The platform follows these principles:

- encryption enabled for shared platform storage and logging paths
- IAM role-based access
- least privilege
- no public storage
- no exposed secrets
- no hardcoded users
- no real credentials in source control
- clear separation between platform and product responsibilities
- auditability through account-level CloudTrail

## Identity and Access

Access should be granted through IAM roles, not hardcoded users.

Role patterns are:

- Platform Admin Role
- CI/CD Deployment Role
- Product Deployment Role

The Platform Admin Role is for controlled platform administration.

The CI/CD Deployment Role is for GitHub Actions based platform deployment. GitHub OIDC can be created by the platform or supplied externally, and trust policies should be scoped to approved repositories, branches, or environments.

The Product Deployment Role and reusable product deployment permission boundary support future product repositories. Product repositories should deploy their own product resources while staying inside the boundary supplied by the platform.

## Permission Boundary

The product deployment permission boundary is a maximum-permissions guardrail for product deployment roles.

It allows product repositories to manage product-owned resources only within safe constraints and explicitly blocks privilege escalation paths, broad IAM administration, CloudTrail tampering, shared bucket administration, and platform KMS administration.

Product repositories should attach the exported `product_deployment_permission_boundary_policy_arn` to product deployment roles they create.

## Least Privilege

Policies should grant only the permissions required for the role's purpose.

Platform roles should manage shared platform resources. Product roles should manage product-owned resources. Product access to shared platform resources should be limited to required actions such as reading/writing approved S3 locations, using approved log groups, and reading approved product secrets.

## Storage Security

All platform S3 buckets must have:

- encryption enabled
- versioning enabled
- public access blocked
- lifecycle rules configured

CloudTrail logs are delivered to the platform logs bucket under a dedicated prefix. Product repositories must not delete shared platform buckets or alter shared bucket policies, encryption, or lifecycle rules.

## KMS Security

The platform KMS key is shared platform infrastructure.

The KMS key policy grants platform services such as CloudTrail and CloudWatch Logs the minimum permissions they need to encrypt platform logs. Product deployment boundaries deny platform KMS administration actions such as changing key policy, disabling keys, revoking grants, or scheduling deletion.

## Terraform State Security

Terraform state can contain sensitive infrastructure metadata.

The remote state backend must use:

- encrypted S3 state storage
- S3 bucket versioning
- public access blocking
- DynamoDB state locking

Access to state should be limited to platform administrators and approved deployment automation.

## Secrets Security

AWS Secrets Manager provides the secrets baseline.

The platform may create placeholder secret structures, but real credentials must not be committed to source control.

Secrets should not be stored in:

- Terraform variable files committed to Git
- Markdown documentation
- scripts
- GitHub workflow files
- application configuration files

Product repositories own product-specific secret values and should use the shared naming and access conventions.

## Network Security

Networking includes:

- VPC
- public subnet
- private subnet
- internet gateway
- optional VPC endpoints

VPC endpoints are disabled by default because interface endpoints add cost. When enabled, they support private access to S3, CloudWatch Logs, Secrets Manager, STS, Glue, and KMS. The platform does not create NAT Gateway or advanced network controls unless explicitly added to scope.

## Audit, Logging, and Monitoring

The platform includes:

- account-level CloudTrail baseline
- CloudTrail log file validation
- CloudTrail delivery to the platform logs bucket
- platform CloudWatch log groups
- basic platform error-count and deployment failure placeholder alarms

Product-specific alarms for IoT Core, EventBridge product rules, Lambda functions, Glue jobs, API Gateway, dbt, Streamlit, or product applications belong in product repositories.

## Lakehouse Catalog Security

The lakehouse module defines shared Glue Catalog conventions and may create a generic platform database marker.

Product repositories own product Glue databases, product Iceberg tables, crawlers, jobs, and table permissions. The platform should not create product table definitions or business data models.

## Product Responsibilities

The following remain product repository responsibilities:

- IoT Core resources
- EventBridge product rules
- Lambda functions
- Glue jobs
- API Gateway APIs
- product Iceberg tables
- dbt projects
- Streamlit apps
- product-specific monitoring and alarms

## Future Security Enhancements

Future versions may add:

- multi-account isolation
- tighter network controls
- richer monitoring and alerting
- cost and anomaly detection
- dedicated product KMS key patterns
- Lake Formation or fine-grained catalog permissions

These should be added only when they remain reusable platform concerns.
