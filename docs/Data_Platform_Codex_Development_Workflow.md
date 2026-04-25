
# Data Platform Demo — Codex / Copilot Workflow

This file defines step-by-step development prompts
for building the Data Platform Demo repository.

---

# Phase -1 — Before Starting


Read docs/Guidance.md carefully.
Read README.md

Familiarize yourself with the project Purpose and Structure

Read docs/architecture-v1.md carefully.

Do not write Terraform code yet.

Summarize the platform components that must be built in V1
and list their dependency order.

Do not add components that are not listed.

---

# Phase 0 — Repository Skeleton

Prompt:

Read README.md and GUIDANCE.md.

Create folder structure:

docs/
docs/adr/
terraform/bootstrap/
terraform/modules/
terraform/environments/dev/
terraform/environments/test/
terraform/environments/prod/
scripts/
.github/workflows/

Add placeholder README.md files.

Do not create Terraform code.

---

# Phase 1 — Architecture Docs

Prompt:

Create documentation:

docs/architecture.md
docs/platform-scope.md
docs/naming-conventions.md
docs/security-model.md
docs/environment-strategy.md
docs/tagging-strategy.md
docs/module-boundaries.md

Do not generate infrastructure code.

---

# Phase 2 — Bootstrap

Prompt:

Create Terraform bootstrap module.

Include:

- S3 bucket for state
- DynamoDB locking
- Encryption enabled

Do not create networking yet.

---

# Phase 3 — Networking

Prompt:

Create Terraform networking module.

Include:

- VPC
- Public subnet
- Private subnet
- Internet Gateway

Keep minimal.

---

# Phase 4 — Storage

Prompt:

Create storage module.

Include:

- Raw bucket
- Logs bucket
- Artifacts bucket

Enable encryption and versioning.

---

# Phase 5 — IAM

Prompt:

Create IAM roles:

- Platform Admin
- CI/CD
- Product Deployment

Use least privilege.

---

# Phase 6 — Logging

Prompt:

Create logging module.

Include:

- Log groups
- Basic alarms

---

# Phase 7 — Secrets

Prompt:

Create Secrets Manager module.

Add placeholder secret.

Do not add real credentials.

---

# Phase 8 — Environment Wiring

Prompt:

Wire modules into:

terraform/environments/dev
terraform/environments/test
terraform/environments/prod

Keep consistent configuration.

---

# Phase 9 — CI/CD

Prompt:

Create GitHub workflow:

terraform fmt
terraform validate
terraform plan

Manual approval required for apply.

---

# Rules

You check:

- Architecture
- Security
- Naming
- Cost

Tool handles:

- Boilerplate
- Module structure
- Outputs
- Documentation drafts

---

# Working Rhythm

1. Ask tool to propose
2. Review assumptions
3. Approve
4. Generate
5. Validate
6. Commit
7. Repeat
