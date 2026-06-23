# Standards

This document defines repository-wide naming and tagging standards for shared platform resources.

## Naming

Use this base pattern where the AWS service allows it:

```text
<project>-<environment>-<component>
```

Examples:

```text
data-platform-dev-vpc
data-platform-dev-raw
data-platform-prod-logs
```

Use these values consistently:

| Part | Values |
| --- | --- |
| `project` | `data-platform` |
| `environment` | `dev`, `test`, `prod` |
| `component` | resource purpose, such as `vpc`, `raw`, `logs`, `platform-admin`, or `product-deployment` |

S3 bucket names must be globally unique, so append a documented suffix:

```text
<project>-<environment>-<component>-<unique-suffix>
```

General naming rules:

- use lowercase where possible
- use hyphens for AWS resource names
- avoid personal names and hardcoded account-specific values
- name IAM roles by access pattern, not by person
- keep names descriptive enough to understand from AWS console lists

Secrets should use path-style names:

```text
data-platform/<environment>/<integration-or-purpose>
```

Real secret values must be added through secure operational processes, not committed to Git.

## Tagging

Apply these tags to every taggable platform resource:

| Tag | Purpose |
| --- | --- |
| `Project` | platform identifier, such as `Data Platform Demo` |
| `Environment` | `dev`, `test`, or `prod` |
| `Owner` | responsible team or role |
| `CostCenter` | cost allocation value |
| `ManagedBy` | management tool, normally `Terraform` |

Tagging rules:

- keep tag keys stable across environments
- use clear values that make sense outside the codebase
- do not use personal names as owner values
- do not put secrets or sensitive values in tags
- document intentional environment-specific tag differences

Optional tags such as `Application`, `Component`, `DataClassification`, `Compliance`, `Repository`, or `ServiceLevel` should be added only when they support a real governance or operating need.
