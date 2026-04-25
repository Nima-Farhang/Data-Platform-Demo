# Tagging Strategy

## Purpose

Tags make platform resources easier to track, audit, govern, and allocate by cost.

Every taggable V1 resource should include the standard platform tags.

## Required Tags

Every resource should include:

```text
Project
Environment
Owner
CostCenter
ManagedBy
```

## Tag Definitions

`Project` identifies the platform.

Expected value:

```text
Data Platform Demo
```

`Environment` identifies where the resource is deployed.

Allowed values:

```text
dev
test
prod
```

`Owner` identifies the team or role responsible for the resource.

Example:

```text
Data Platform
```

`CostCenter` identifies the cost allocation group.

For the demo, this can be a placeholder value, but it should be consistently applied.

`ManagedBy` identifies the management tool.

Expected value:

```text
Terraform
```

## Optional Tags

Future versions may add:

- Application
- Component
- DataClassification
- Compliance
- Repository
- ServiceLevel

Optional tags should be added only when they support a real governance or operating need.

## Tagging Rules

- Apply tags consistently across environments.
- Keep tag keys stable.
- Use clear values that can be understood outside the codebase.
- Do not use personal names as owner values.
- Do not include secrets or sensitive values in tags.
- Avoid environment-specific tag drift unless intentional and documented.

## Governance Uses

Tags support:

- cost tracking
- resource auditing
- ownership lookup
- operational reporting
- environment filtering
- cleanup reviews

## V1 Standard

A V1 resource should not be considered complete until required tags are applied where the AWS service supports tagging.
