# Security Model

## Purpose

The V1 security model provides a practical baseline for a small, production-minded data platform foundation.

The goal is to reduce avoidable risk without adding unnecessary enterprise complexity too early.

## Security Principles

V1 follows these principles:

- encryption enabled everywhere
- IAM role-based access
- least privilege
- no public storage
- no exposed secrets
- no hardcoded users
- no real credentials in source control
- clear separation between platform and product responsibilities

## Identity and Access

Access should be granted through IAM roles, not hardcoded users.

V1 role patterns are:

- Platform Admin Role
- CI/CD Deployment Role
- Product Deployment Role

The Platform Admin Role is for controlled platform administration.

The CI/CD Deployment Role is for GitHub Actions based deployment.

The Product Deployment Role is for future data product repositories that need to consume platform resources or deploy product-owned resources.

## Least Privilege

Policies should grant only the permissions required for the role's purpose.

Wildcard permissions should be avoided.

Where broad permissions are temporarily needed during early development, they should be treated as temporary and tightened before V1 is considered complete.

## Storage Security

All platform S3 buckets must have:

- encryption enabled
- versioning enabled
- public access blocked
- lifecycle rules configured

Buckets must not allow public read or public write access.

## Terraform State Security

Terraform state can contain sensitive infrastructure metadata.

The remote state backend must use:

- encrypted S3 state storage
- S3 bucket versioning
- public access blocking
- DynamoDB state locking

Access to state should be limited to platform administrators and approved deployment automation.

## Secrets Security

AWS Secrets Manager provides the V1 secrets baseline.

V1 may create placeholder secret structures, but real credentials must not be committed to source control.

Secrets should not be stored in:

- Terraform variable files committed to Git
- Markdown documentation
- scripts
- GitHub workflow files
- application configuration files

## Network Security

V1 networking is intentionally minimal.

It includes:

- VPC
- public subnet
- private subnet
- internet gateway

V1 does not include private endpoints, custom KMS keys, NAT Gateway, or advanced network ACL rules unless a later requirement justifies them.

## Logging and Monitoring

The platform should include CloudWatch Log Groups and basic metric alarms.

Logging supports:

- troubleshooting
- deployment visibility
- platform health checks
- audit readiness

## Future Security Enhancements

Future versions may add:

- custom KMS keys
- private endpoints
- tighter network ACL rules
- multi-account isolation
- more detailed monitoring and alerting
- cost and anomaly detection

These are future enhancements and should not expand the V1 scope unless required.
