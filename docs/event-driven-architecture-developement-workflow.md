# Platform Demo Repository Workflow

## Purpose

This workflow defines the next set of platform-specific components to add to the **Data Platform Demo** repository so it can support the new **Event-Driven Lakehouse Demo** product while preserving the existing platform/product boundary.

The work must follow the same patterns already defined in the repository:

- reusable Terraform modules under `terraform/modules/`
- environment composition under `terraform/environments/dev`, `test`, and `prod`
- bootstrap resources isolated under `terraform/bootstrap/`
- explicit module inputs and outputs
- no product-specific resources in the platform repository
- no business logic, data pipelines, dbt models, Streamlit apps, APIs, or product-specific table definitions
- common naming, tagging, security, and environment conventions already documented in the repository

The platform repository should only provide shared foundations and controlled interfaces that future product repositories can consume.

---

## Components to Build

The following components should be added to the platform repository because they are shared foundations or reusable guardrails.

| Component | Platform responsibility | Why it belongs in platform |
|---|---|---|
| GitHub OIDC provider | Create reusable GitHub Actions trust foundation | Multiple repos will use GitHub Actions to deploy infrastructure safely |
| Shared KMS key | Provide customer-managed encryption baseline | Shared buckets, logs, Glue, and future resources can use a standard encryption key |
| Curated/lakehouse S3 bucket | Add shared curated storage alongside raw/logs/artifacts | Lakehouse products need a governed curated storage layer |
| CloudTrail baseline | Enable account-level audit logging | Audit logging is platform/security foundation, not product logic |
| CloudWatch/logging baseline | Create shared log groups, retention defaults, and basic alarms | Products should inherit logging standards instead of inventing them |
| Glue Data Catalog baseline | Create shared catalog foundation for Iceberg/lakehouse products | Product repos can create product databases/tables against a common catalog convention |
| Product IAM permission boundary | Restrict what product deployment roles can create | Allows product repos to own their resources without granting uncontrolled permissions |
| Platform output interface | Expose required shared values to product repos | Product repos need stable outputs such as bucket names, role ARNs, KMS key ARN, and catalog names |
| Optional VPC endpoints | Add private access baseline for S3, CloudWatch Logs, Secrets Manager, STS, Glue | Needed if future products run private Lambdas/Glue jobs inside VPC |

The following components must **not** be added to the platform repository:

| Component | Belongs in product repo |
|---|---|
| IoT Core topics and rules | Event-Driven Lakehouse Demo repo |
| EventBridge product bus/rules | Event-Driven Lakehouse Demo repo |
| Product Lambda functions | Event-Driven Lakehouse Demo repo |
| Product API Gateway | Event-Driven Lakehouse Demo repo |
| Product Glue jobs | Event-Driven Lakehouse Demo repo |
| Product Iceberg tables | Event-Driven Lakehouse Demo repo |
| Product S3 prefixes and data layout | Event-Driven Lakehouse Demo repo |
| dbt models | Product repo |
| Streamlit dashboards | Product repo |
| Business schemas and metrics | Product repo |

---

## Development Principles

Before implementing any component, confirm it satisfies this rule:

> A resource belongs in the platform repository only if it is reusable across multiple products or required to operate the shared platform foundation.

Every implementation step should follow these repository patterns:

1. Add reusable logic inside a focused module under `terraform/modules/`.
2. Keep module internals free of product-specific assumptions.
3. Wire modules through the root environment composition.
4. Expose only required outputs.
5. Update `dev`, `test`, and `prod` tfvars consistently.
6. Update docs and ADRs when the platform scope changes.
7. Validate with `terraform fmt`, `terraform validate`, and a clean plan.

---

# Step-by-Step Development Prompts

Use the prompts below one at a time with Codex or another coding agent. Each prompt is intentionally scoped so the implementation remains reviewable.

---

## Step 1 — Review Existing Repository Patterns

### Prompt

```text
Study the current Data Platform Demo repository before making changes.

Focus on:
- terraform module structure
- environment composition pattern
- naming conventions
- tagging strategy
- existing storage, IAM, networking, logging, and secrets modules
- docs/adr decisions
- README.md
- platform/product boundary rules

Do not write code yet.

Produce a short implementation plan that explains how the new platform components should be added while preserving the existing repository patterns.
```

### Acceptance Criteria

- Existing module boundaries are understood.
- No product-specific resources are proposed for the platform repo.
- Implementation plan references current repository conventions.
- Plan identifies which existing modules should be extended and which new modules should be created.

---

## Step 2 — Add Shared KMS Module

### Prompt

```text
Add a reusable Terraform module for platform-managed KMS encryption.

Requirements:
- Create a new module under terraform/modules/kms.
- Create one platform KMS key per environment.
- Create a friendly alias using the repository naming convention.
- Enable key rotation.
- Add tags using the existing common_tags pattern.
- Expose key_id, key_arn, and alias outputs.
- Wire the module into the environment composition consistently with existing modules.
- Update variables and outputs as needed.
- Do not create product-specific keys.
- Do not store secrets or credentials.
```

### Acceptance Criteria

- `terraform/modules/kms` exists with `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, and `README.md`.
- KMS key uses environment-aware naming.
- Key rotation is enabled.
- Root outputs expose the KMS key ARN.
- Existing S3 buckets can later consume the KMS key without changing module boundaries.
- Terraform format and validation pass.

---

## Step 3 — Upgrade Shared Storage for Curated Lakehouse Storage

### Prompt

```text
Extend the existing storage module to support a shared curated/lakehouse S3 bucket.

Requirements:
- Preserve the existing storage module pattern.
- Add a curated bucket alongside the existing raw, logs, and artifacts buckets.
- Use the same naming, tagging, versioning, lifecycle, and public access block patterns as existing buckets.
- Update encryption to optionally use the platform KMS key if provided.
- Expose curated bucket name and ARN outputs.
- Update root outputs so product repos can consume raw, logs, artifacts, and curated bucket details.
- Do not add product-specific prefixes or product-specific S3 layouts.
```

### Acceptance Criteria

- Curated bucket is created per environment.
- Existing raw/logs/artifacts bucket behavior is preserved.
- Curated bucket has encryption, versioning, lifecycle rules, and public access block.
- Storage module remains generic and reusable.
- Product-specific paths such as `iot/`, `sensor/`, `raw/events/`, or `curated/tables/` are not created.
- Root outputs include all shared bucket names and ARNs.

---

## Step 4 — Add GitHub OIDC Provider Foundation

### Prompt

```text
Add GitHub OIDC provider support to the platform IAM foundation.

Requirements:
- Create or extend the IAM module so the platform can create the GitHub OIDC provider when enabled.
- Preserve support for the existing github_oidc_provider_arn input if the provider is already managed externally.
- Define clear variables for GitHub organization, allowed repositories, and allowed branches/environments.
- Update the CI/CD deployment role trust policy to use least privilege repository conditions.
- Keep product repo access controlled through product deployment roles.
- Do not hardcode personal users or one-off repository names unless they are variables.
```

### Acceptance Criteria

- Platform can either create or reference a GitHub OIDC provider.
- Deployment role trust policy is restricted to configured GitHub org/repo/branch or environment patterns.
- No broad `repo:*` trust is introduced unless explicitly configured.
- Existing IAM outputs remain backward-compatible where practical.
- README/docs explain how product repositories consume the deployment role.

---

## Step 5 — Add Product IAM Permission Boundary

### Prompt

```text
Add a reusable IAM permission boundary for product deployment roles.

Requirements:
- Implement the permission boundary inside the IAM module or a clearly separated IAM submodule.
- The boundary should allow product repos to manage product-owned resources such as Lambda, Glue jobs, EventBridge rules, API Gateway, CloudWatch log groups, and product IAM roles only within safe constraints.
- Restrict access to shared platform resources to required actions only.
- Prevent privilege escalation, unrestricted IAM admin, disabling CloudTrail, deleting shared buckets, or modifying platform KMS policies.
- Expose the permission boundary policy ARN as an output.
- Attach or document how it should be attached to product deployment roles.
```

### Acceptance Criteria

- Permission boundary policy exists and is output from the platform stack.
- Product deployment role can be constrained by the boundary.
- Boundary prevents broad IAM escalation.
- Boundary does not grant access to product resources by itself; it only limits maximum permissions.
- Documentation clearly explains the difference between the deployment role policy and the permission boundary.

---

## Step 6 — Add CloudTrail Audit Baseline

### Prompt

```text
Add a CloudTrail audit baseline to the platform repository.

Requirements:
- Create a new module under terraform/modules/audit or terraform/modules/cloudtrail.
- Create an account-level CloudTrail trail per environment/account design.
- Store CloudTrail logs in the existing platform logs bucket or a clearly named audit bucket if the current pattern requires separation.
- Use the platform KMS key if available.
- Enable log file validation.
- Add lifecycle retention using the existing storage conventions.
- Expose trail name, trail ARN, and log bucket/prefix outputs.
- Do not create product-specific audit trails.
```

### Acceptance Criteria

- CloudTrail is enabled through a reusable module.
- Logs are encrypted and stored in platform-owned storage.
- Log file validation is enabled.
- CloudTrail cannot be disabled by product deployment roles.
- Outputs are available for documentation and downstream monitoring.
- Docs explain that product repos do not create their own baseline audit trails.

---

## Step 7 — Complete CloudWatch Logging Baseline

### Prompt

```text
Review and complete the existing logging module so it provides a reusable platform logging baseline.

Requirements:
- Preserve the current logging module boundary.
- Add standard CloudWatch log group naming and retention variables.
- Create platform-level log groups where appropriate.
- Add basic platform alarms, such as deployment failure placeholders or error-count metric alarm patterns if already compatible with the repo style.
- Do not create product-specific Lambda, Glue, API Gateway, or IoT alarms.
- Expose log group names and ARNs needed by product repositories.
```

### Acceptance Criteria

- Logging module has clear inputs and outputs.
- Log retention is configurable per environment.
- No product-specific monitoring is added.
- Product repos can follow the naming/retention pattern for their own logs.
- Documentation distinguishes platform logging baseline from product observability.

---

## Step 8 — Add Glue Catalog / Lakehouse Baseline

### Prompt

```text
Add a reusable lakehouse/catalog foundation for future Iceberg-based products.

Requirements:
- Create a new module under terraform/modules/lakehouse or terraform/modules/catalog.
- Define shared Glue Catalog conventions only.
- Optionally create a platform-level Glue database namespace if it is generic, such as a shared technical database or environment-level catalog marker.
- Provide variables and outputs for catalog ID, curated bucket location, and naming conventions.
- Do not create product-specific Glue databases, Glue tables, crawlers, Glue jobs, or Iceberg table definitions.
- Document how product repositories should create their own product databases and Iceberg tables using this baseline.
```

### Acceptance Criteria

- Module provides shared Glue/lakehouse foundation without product-specific resources.
- No IoT-specific database or table is created.
- Curated bucket and KMS key outputs are available to product repos.
- Documentation explains the platform/product split for Glue and Iceberg.
- Future product repos can consume catalog/storage outputs cleanly.

---

## Step 9 — Optional: Add VPC Endpoints Baseline

### Prompt

```text
Add optional VPC endpoint support to the networking module or a focused vpc_endpoints module.

Requirements:
- Keep the feature optional and disabled by default if it increases cost or complexity.
- Support endpoints commonly needed by private workloads: S3, CloudWatch Logs, Secrets Manager, STS, Glue, and KMS.
- Follow existing networking module conventions.
- Do not add NAT Gateway or advanced networking unless explicitly required by the repository scope.
- Expose endpoint IDs as outputs.
```

### Acceptance Criteria

- VPC endpoints are optional.
- Existing networking behavior is preserved when endpoints are disabled.
- Endpoint creation follows naming and tagging standards.
- No product-specific network rules are created.
- Documentation explains when product repos need these outputs.

---

## Step 10 — Update Documentation and ADRs

### Prompt

```text
Update the repository documentation to reflect the new platform scope.

Requirements:
- Update docs/platform-scope.md.
- Update docs/module-boundaries.md.
- Update docs/security-model.md.
- Update docs/architecture.md.
- Add a new ADR explaining the v2 platform foundation expansion.
- Clearly state that IoT Core, EventBridge product rules, Lambda functions, Glue jobs, API Gateway, product Iceberg tables, dbt, and Streamlit remain product repository responsibilities.
- Add a product onboarding section listing the outputs product repos should consume.
```

### Acceptance Criteria

- Docs match the implemented Terraform.
- New scope is clearly identified as an expansion from the original V1 scope.
- Platform/product boundary remains explicit.
- ADR explains why the new components belong in platform.
- Product onboarding outputs are documented.

---

## Step 11 — Validate Terraform and Repository Quality

### Prompt

```text
Run repository validation and fix any issues.

Requirements:
- Run terraform fmt recursively.
- Run terraform validate for bootstrap and each environment composition.
- Run terraform plan for dev using the documented backend/tfvars pattern.
- Check that no generated files, state files, credentials, secrets, or local provider files are committed.
- Check that all new modules have README files.
- Check that outputs are meaningful and not excessive.
```

### Acceptance Criteria

- `terraform fmt -recursive` passes.
- `terraform validate` passes for all relevant Terraform roots.
- `terraform plan` for dev completes successfully.
- No secrets or state files are committed.
- All new modules have documentation.
- CI/CD workflow still matches repository conventions.

---

# Final Acceptance Criteria

The platform repository is complete for this phase when all of the following are true:

## Functional Acceptance

- Platform creates or references a GitHub OIDC provider.
- Platform provides shared KMS encryption foundation.
- Platform provides raw, logs, artifacts, and curated S3 buckets.
- Platform provides CloudTrail audit baseline.
- Platform provides reusable CloudWatch/logging baseline.
- Platform provides Glue/lakehouse catalog baseline without product tables.
- Platform exposes a product IAM permission boundary.
- Platform outputs all shared values required by product repositories.

## Boundary Acceptance

- No IoT Core resources are created in the platform repo.
- No EventBridge product rules are created in the platform repo.
- No product Lambda functions are created in the platform repo.
- No product API Gateway resources are created in the platform repo.
- No product Glue jobs are created in the platform repo.
- No product Iceberg tables are created in the platform repo.
- No dbt or Streamlit resources are created in the platform repo.
- No business-specific schemas, metrics, or dashboards are created in the platform repo.

## Repository Pattern Acceptance

- Existing module structure is preserved.
- New modules are focused and reusable.
- Environment composition wires modules consistently.
- Naming and tagging conventions are followed.
- Outputs are explicit and stable.
- Documentation and ADRs are updated.
- Terraform formatting and validation pass.

## Product Readiness Acceptance

The Event-Driven Lakehouse Demo repository should be able to consume platform outputs such as:

- platform deployment role ARN
- product deployment role ARN
- permission boundary ARN
- raw bucket name and ARN
- curated bucket name and ARN
- logs bucket name and ARN
- artifacts bucket name and ARN
- KMS key ARN
- Glue catalog ID or lakehouse baseline outputs
- VPC ID and subnet IDs, if private workloads are used
- VPC endpoint IDs, if enabled

After this phase, the product repository should own the full workload-specific implementation from ingestion to serving:

```text
IoT Core -> EventBridge -> Lambda -> S3 product prefixes -> Glue jobs -> Iceberg tables -> API Gateway -> Snowflake/dbt/Streamlit
```

The platform repository should remain the shared foundation underneath that product workload.
