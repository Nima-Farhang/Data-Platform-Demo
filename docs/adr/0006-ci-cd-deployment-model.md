# 0006 — CI/CD Deployment Model

## Status

Accepted

## Context

The platform should support repeatable infrastructure deployment through automation.

Because platform changes affect shared foundations, deployments should include validation, planning, and human approval before applying changes.

## Decision

GitHub Actions is the CI/CD system for platform deployment.

The expected deployment flow is:

```text
Code Commit
      |
      v
terraform fmt
      |
      v
terraform validate
      |
      v
terraform plan
      |
      v
Manual Approval
      |
      v
terraform apply
```

The CI/CD Deployment Role is the role pattern used by GitHub Actions to deploy platform infrastructure.

## Consequences

Infrastructure changes are formatted, validated, and planned before apply.

Manual approval creates a review point before shared platform infrastructure changes.

The deployment model is simple enough for V1 while leaving room for future environment-specific approvals and policy checks.

## Related Documents

- `docs/architecture.md`
- `docs/security-model.md`
- `docs/environment-strategy.md`
