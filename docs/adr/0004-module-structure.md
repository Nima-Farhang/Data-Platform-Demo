# 0004 — Module Structure

## Status

Accepted

## Context

The platform should avoid becoming a single large Terraform root project.

Reusable modules make the platform easier to test, compose, review, and promote across environments. Environment compositions should wire modules together without hiding business or environment-specific assumptions inside the modules.

## Decision

The platform will use reusable modules plus environment compositions.

The expected module boundaries are:

- bootstrap
- networking
- storage
- IAM
- logging
- secrets

Environment folders compose those modules for `dev`, `test`, and `prod`.

Modules should:

- focus on one platform concern
- be reusable across environments
- expose explicit inputs and outputs
- avoid business-specific assumptions
- avoid product-specific resources

Environment compositions should:

- pass environment-specific configuration
- pass common tags
- connect module outputs where needed
- keep Terraform state separate per environment

## Consequences

The platform can grow without turning every change into a root-module edit.

Product-specific infrastructure stays outside the platform modules.

Module outputs become the controlled interface between platform resources, environment wiring, and future product integrations.

## Related Documents

- `docs/module-boundaries.md`
- `docs/environment-strategy.md`
- `docs/architecture.md`
