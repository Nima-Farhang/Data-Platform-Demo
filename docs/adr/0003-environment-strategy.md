# 0003 — Environment Strategy

## Status

Accepted

## Context

The platform needs a safe way to validate infrastructure changes before production use.

Small data platforms still need separation between development, test, and production concerns. Sharing state or configuration across environments increases the risk of accidental changes and environment drift.

## Decision

The platform supports three environments:

- `dev`
- `test`
- `prod`

Each environment must:

- use separate Terraform state
- have independent configuration
- use shared reusable modules
- follow the same naming and tagging standards
- remain deployable without product-specific resources

V1 is considered complete when the `dev` environment deploys cleanly with the required platform components.

## Consequences

Infrastructure changes can be validated in `dev` before promotion.

The same module code can be reused across environments while environment-specific configuration stays explicit.

State separation reduces the risk of one environment accidentally modifying another.

## Related Documents

- `docs/environment-strategy.md`
- `docs/architecture.md`
- `docs/naming-conventions.md`
- `docs/tagging-strategy.md`
