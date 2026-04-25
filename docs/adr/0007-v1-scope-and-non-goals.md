# 0007 — V1 Scope and Non-Goals

## Status

Accepted

## Context

The first version of the platform should be small, deployable, and extensible.

Adding too many services in V1 would make the platform harder to finish, harder to explain, and harder to operate. The initial goal is a stable foundation that future platform and product work can build on safely.

## Decision

V1 includes only:

- Terraform remote state
- networking
- platform storage
- identity and access management
- logging and monitoring
- secrets management
- environment wiring

V1 must be built in this dependency order:

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

V1 explicitly excludes:

- Snowflake provisioning
- Kafka infrastructure
- Kubernetes clusters
- data warehouse configuration
- streaming platforms
- data pipelines
- dbt models
- Streamlit apps
- product-specific storage
- business logic

## Consequences

V1 remains focused on platform foundations rather than business products.

The project can complete a clean deployable baseline before adding data product integration.

Future work can introduce warehouse integration, streaming, metadata services, catalogs, and advanced security after the foundation is stable.

## Related Documents

- `docs/architecture.md`
- `docs/platform-scope.md`
- `docs/adr/0001-v1-platform-architecture.md`
