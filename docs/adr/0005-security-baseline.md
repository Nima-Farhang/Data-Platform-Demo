# 0005 — Security Baseline

## Status

Accepted

## Context

V1 should be simple and low-cost, but it still needs production-minded security defaults.

The platform will manage shared infrastructure that future product repositories may depend on, so insecure defaults would create risk across everything built on top of it.

## Decision

V1 uses the following security baseline:

- encryption enabled everywhere
- IAM role-based access
- least privilege
- no public storage
- no exposed secrets
- no hardcoded users
- no real credentials in source control
- separate Terraform state per environment

The platform will create role patterns for:

- Platform Admin Role
- CI/CD Deployment Role
- Product Deployment Role

Secrets Manager may contain placeholder secret structures in V1, but real credentials must be added only through secure operational processes.

## Consequences

The platform starts with safe defaults without requiring advanced enterprise controls in V1.

IAM policies must be reviewed for least privilege before V1 is considered complete.

Future versions may add custom KMS keys, private endpoints, multi-account isolation, and more advanced monitoring.

## Related Documents

- `docs/security-model.md`
- `docs/environment-strategy.md`
- `docs/standards.md`
