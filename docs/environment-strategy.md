# Environment Strategy

## Purpose

The platform supports multiple environments so changes can be tested safely before production use.

V1 supports:

- `dev`
- `test`
- `prod`

## Environment Principles

Each environment should:

- use separate Terraform state
- have independent configuration
- use the same shared modules
- follow the same naming and tagging standards
- be deployable without depending on product-specific resources

## Development Environment

`dev` is the first environment to compose and deploy.

V1 is considered deployable when the `dev` environment applies cleanly with the required platform components.

`dev` is used to validate:

- module composition
- naming conventions
- tags
- IAM role assumptions
- logging setup
- secrets placeholder structure

## Test Environment

`test` should mirror the platform design used by `dev`, with independent configuration and state.

It is intended for validation before production changes.

`test` should not share Terraform state with `dev` or `prod`.

## Production Environment

`prod` represents the stable platform foundation.

Production changes should be planned, reviewed, and approved before apply.

`prod` should not depend on development-only resources.

## State Separation

Each environment must use separate Terraform state.

State separation prevents changes in one environment from corrupting or unexpectedly modifying another environment.

## Configuration Separation

Each environment should have its own configuration values for:

- environment name
- region where applicable
- naming suffixes where required
- tags
- environment-specific settings

Shared defaults should be centralized where that keeps behavior consistent, but environment-specific values should remain explicit.

## Deployment Order

The platform should be built in this sequence:

```text
Bootstrap
      |
      v
Networking
      |
      v
Storage
      |
      v
IAM
      |
      v
Logging
      |
      v
Secrets
      |
      v
Environment Wiring
```

## Promotion Model

Changes should be validated in `dev` first.

After review, the same module changes can be promoted through `test` and then `prod` using environment-specific configuration.

## V1 Completion Standard

V1 requires the `dev` environment to deploy cleanly.

`test` and `prod` structure should exist as part of the repository strategy, but production readiness depends on review, approval, and operational controls.
