# Environment Strategy

The platform supports `dev`, `test`, and `prod` so changes can be validated before production use.

## Principles

Each environment must:

- use separate Terraform state
- keep independent configuration
- use the same reusable modules
- follow the same standards and security model
- deploy without product-specific resources

## Environment Roles

`dev` is the first validation environment for module composition, IAM assumptions, logging, secrets, naming, and tags.

`test` mirrors the platform design with independent state and configuration for pre-production validation.

`prod` is the stable platform foundation. Production changes should be planned, reviewed, approved, and applied through the documented deployment process.

## Promotion Model

Validate changes in `dev`, promote the same module changes through `test`, then deploy to `prod` with environment-specific configuration.

Shared defaults may be centralized when that keeps behavior consistent, but environment-specific values should remain explicit.

See [Architecture](architecture.md) for the dependency flow and [Standards](standards.md) for environment naming and tags.
