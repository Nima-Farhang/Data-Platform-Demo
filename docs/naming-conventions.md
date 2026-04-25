# Naming Conventions

## Purpose

Consistent naming makes platform resources easier to identify, audit, and operate across environments.

All V1 resources should follow the same naming pattern wherever the target AWS service allows it.

## Standard Pattern

Use:

```text
<project>-<environment>-<component>
```

Example names:

```text
data-platform-dev-vpc
data-platform-dev-raw
data-platform-prod-logs
```

## Name Parts

`project` identifies the platform.

Use:

```text
data-platform
```

`environment` identifies the deployment environment.

Allowed values:

```text
dev
test
prod
```

`component` identifies the resource purpose.

Example component values:

```text
vpc
public-subnet
private-subnet
raw
logs
artifacts
platform-admin
cicd-deployment
product-deployment
```

## S3 Bucket Names

S3 bucket names must be globally unique, so they may require a documented suffix in addition to the standard pattern.

Use the standard pattern as the base:

```text
<project>-<environment>-<component>-<unique-suffix>
```

The suffix should be parameterized or clearly documented. It should not contain hardcoded personal or account-specific values.

## Terraform State Names

Terraform state resources should be named clearly as platform bootstrap resources.

Use names that identify:

- project
- environment or bootstrap scope
- state storage purpose
- lock table purpose

## IAM Role Names

IAM role names should describe the access pattern rather than a person.

Use role-oriented names such as:

```text
data-platform-dev-platform-admin
data-platform-dev-cicd-deployment
data-platform-dev-product-deployment
```

Do not include individual usernames in role names.

## CloudWatch Names

CloudWatch Log Groups and alarms should include project, environment, and component names.

Examples:

```text
data-platform-dev-platform-logs
data-platform-dev-storage-errors
```

## Secrets Names

Secrets should be grouped by project, environment, and intended integration.

Example:

```text
data-platform/dev/example-secret
```

Secrets should use placeholder values during V1 setup. Real secret values must be added through secure operational processes, not committed to Git.

## General Rules

- Use lowercase names where AWS service constraints allow.
- Use hyphens for resource names.
- Avoid abbreviations unless they are common AWS terms.
- Avoid hardcoded account-specific identifiers.
- Avoid personal names.
- Keep names descriptive enough to understand purpose from an AWS console list.
