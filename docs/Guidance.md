# Data Platform Demo — Development Guidance

## 1. Purpose of the new repository

The new repository should be called:

```text
data-platform-demo
```

Its purpose is to demonstrate a reusable, self-contained **data platform bootstrap blueprint**.

This repository is not a single business data product. It is the platform foundation that allows future data product repositories to be deployed safely and consistently.

The intended positioning is:

> A production-style platform foundation for small companies that need a clean, governed, extensible data platform without starting from a large enterprise architecture.

This aligns with the broader company idea: building reusable data product and data platform blueprints for small and mid-sized organisations.

---

## 2. Review of Data Product Demo

The `Data-Product-Demo` repository is a good reference pattern for the new `Data Platform Demo` repository.

### What the Data Product Demo does well

It is a self-contained data product repository with:

- Terraform for product-specific Snowflake infrastructure
- dbt for transformation and modelling
- Streamlit apps for product-facing consumption
- GitHub Actions for deployment automation
- Codespaces/devcontainer support for repeatable development
- Clear documentation through `README.md`, `QUICKSTART.md`, and layer-specific docs

### Core design pattern

The Data Product Demo follows this structure:

```text
Repository
├── TERRAFORM/       Product-specific Snowflake objects
├── DBT/             Product-specific data models
├── STREAMLIT/       Product-specific apps
├── .github/         Product-specific CI/CD
└── .devcontainer/   Developer environment
```

### Important lesson for the new platform repository

The Data Product Demo proves the pattern of:

> One repository = one deployable unit with infrastructure, automation, and documentation.

The new `Data Platform Demo` should follow the same principle, but at the platform layer instead of the product layer.

---

## 3. Review of the Terraform repository

The uploaded Terraform repository is much more relevant to the `Data Platform Demo` idea than the earlier `Data Platform Framework` repository.

### Current Terraform repository structure

The current structure is broadly:

```text
Terraform-master/
├── .devcontainer/
├── bootstraps/
├── networking/
├── data_platform/
├── setup.sh
├── commands.txt
├── requirement.txt
└── README.md
```

### What works well

The repository already has several useful ideas:

1. **Bootstrap-first thinking**

   The `bootstraps/` folder creates:

   - S3 bucket for Terraform remote state
   - DynamoDB table for state locking
   - S3 versioning
   - S3 encryption
   - public access blocking

   This is the correct first step for a serious Terraform-based platform.

2. **Separation of infrastructure layers**

   Separate folders exist for:

   - bootstrap resources
   - networking
   - data platform resources

   This is a good foundation for future layering.

3. **Remote state usage**

   The `networking/` and `data_platform/` folders already use S3 backend configuration.

4. **AWS-first platform direction**

   This matches the intended platform direction and your current AWS/Snowflake career narrative.

### What needs improvement before turning it into Data Platform Demo

The current Terraform repo is a good prototype, but not yet a polished platform demo.

Main gaps:

1. **Hard-coded account-specific values**

   Examples:

   - bucket suffixes
   - AWS account identifiers
   - backend bucket names
   - region values

   These should be parameterised or documented clearly.

2. **No reusable module structure yet**

   The current folders are root Terraform projects, not reusable modules.

   For a platform demo, use both:

   - reusable modules
   - environment compositions

3. **Networking folder is not really networking yet**

   The current `networking/` layer creates an S3 bucket named `networking-main...`.

   For a platform blueprint, networking should eventually include:

   - VPC
   - private/public subnets if needed
   - route tables
   - VPC endpoints for S3/Secrets/CloudWatch where appropriate

   However, for a minimal demo, we can start without heavy networking if the platform is serverless/S3/Snowflake-first.

4. **Data platform folder is currently too small**

   It creates a landing bucket only. This is a good start, but the platform demo should include a clearer shared data lake structure.

5. **No CI/CD workflows yet**

   The Data Product Demo has useful GitHub Actions. The new platform repository should include Terraform validation and plan/apply workflows.

6. **No clear environment model**

   The current repo mostly assumes `dev`. The demo should support at least `dev`, with structure ready for `test` and `prod`.

7. **No platform documentation pattern yet**

   The new repository should include architecture notes, decisions, and runbooks.

---

## 4. Repository responsibility boundary

This is the most important design rule.

### Data Platform Demo owns shared platform infrastructure

The platform repository should create:

- Terraform remote state backend
- VPC networking baseline
- shared platform S3 storage
- IAM roles
- logging baseline
- Secrets Manager baseline
- CI/CD deployment role
- outputs that product repositories can consume

### Data Product Demo owns product-specific infrastructure

The product repository should create:

- product Snowflake database
- product Snowflake schemas
- product warehouse
- product resource monitor
- product service user
- dbt project
- product Streamlit apps
- product-specific S3 prefixes or buckets if required
- product-specific ingestion resources if required

### Boundary rule

Use this rule:

> If an infrastructure component is reused by multiple products, it belongs in Data Platform Demo. If it exists only for one business use case, it belongs in Data Product Demo.

---

## 5. Basic infrastructure Data Platform Demo should build

For version 1, keep it small, clean, and professional.

Do not overbuild.

The platform demo should create only the locked V1 infrastructure defined in `docs/adr/0001-v1-platform-architecture.md`.

V1 includes only:

- Terraform remote state backend
- VPC networking baseline
- Shared platform S3 storage
- IAM roles
- Logging baseline
- Secrets Manager baseline
- CI/CD deployment role

V1 explicitly excludes:

- Snowflake provisioning
- dbt models
- Streamlit apps
- Kafka
- Kubernetes
- Data pipelines
- Product-specific infrastructure
- Business dashboards

---

### 5.1 Terraform bootstrap backend

Purpose:

- Store Terraform state remotely
- Support safe collaboration
- Prevent state corruption

Resources:

- S3 bucket for Terraform state
- DynamoDB table for state locking
- S3 versioning
- S3 server-side encryption
- S3 public access block

This already exists in the current Terraform repo and should be retained, cleaned up, and documented.

Recommended naming pattern:

```text
<project>-terraform-state-<environment>-<account-suffix>
<project>-terraform-lock-<environment>
```

Example:

```text
data-platform-demo-terraform-state-dev-123456789012
data-platform-demo-terraform-lock-dev
```

---

### 5.2 Shared data lake buckets

Purpose:

- Provide standard shared landing zones for future data products
- Demonstrate a clean lake-style platform foundation

Recommended buckets:

```text
data-platform-demo-raw-<environment>-<account-suffix>
data-platform-demo-artifacts-<environment>-<account-suffix>
data-platform-demo-logs-<environment>-<account-suffix>
```

Recommended zones:

- `raw`: immutable source-aligned landing data
- `artifacts`: deployment artifacts, scripts, packaged jobs
- `logs`: platform and pipeline logs

For a demo, separate buckets make the architecture easier to understand. In production, this could also be implemented as one bucket with zone prefixes.

Required controls:

- block public access
- server-side encryption
- versioning where appropriate
- lifecycle rules for temporary/log data
- standard tags

---

### 5.3 IAM roles and policies

Purpose:

- Demonstrate secure platform access patterns
- Avoid using long-lived personal credentials
- Prepare for CI/CD and product deployments

Recommended roles:

```text
DataPlatformAdminRole
DataPlatformCicdRole
DataProductDeploymentRole
```

Minimal responsibilities:

- `DataPlatformAdminRole`: admin-level platform operations, used carefully
- `DataPlatformCicdRole`: GitHub Actions/Terraform deployment role
- `DataProductDeploymentRole`: role that future product repos can assume for product-specific deployment

Important design note:

The platform repo does not provision Snowflake in V1. Product repos should create their own Snowflake stages, databases, schemas, and grants.

---

### 5.4 Secrets baseline

Purpose:

- Provide a safe place for future credentials and integration values

Recommended AWS Secrets Manager structure:

```text
/data-platform-demo/dev/github/deployment
/data-platform-demo/dev/shared/api-placeholder
```

For the demo, avoid storing real secrets. Create placeholder secret structures or document how secrets should be created manually.

Recommended approach:

- Terraform can create secret containers
- Secret values should be injected outside source control
- Never commit secret values

---

### 5.5 Logging and monitoring baseline

Purpose:

- Show that this is a production-minded platform, not just storage creation

Recommended resources:

- CloudWatch log groups
- basic CloudWatch alarms where useful

Minimal version:

```text
/platform/data-platform-demo/dev
/platform/data-platform-demo/dev/terraform
/platform/data-platform-demo/dev/ingestion
```

This gives later Glue/Lambda/ingestion modules somewhere consistent to send logs.

---

### 5.6 VPC networking baseline

V1 includes a minimal VPC networking baseline.

Recommended v1 networking scope:

- VPC
- public subnet
- private subnet
- internet gateway

Do not include NAT gateways, private endpoints, multi-AZ complexity, or advanced networking in V1.

Recommended future networking scope:

- VPC endpoints for S3, Secrets Manager, CloudWatch
- security groups
- route tables

---

### 5.7 CI/CD baseline

Purpose:

- Mirror the professional pattern already shown in Data Product Demo
- Make the repository self-contained

Recommended GitHub Actions:

```text
.github/workflows/terraform-ci.yml
.github/workflows/terraform-apply-dev.yml
```

Initial workflow responsibilities:

- terraform fmt
- terraform validate
- terraform plan
- optional apply to dev on merge to main/master

Do not apply automatically to prod in the first demo.

---

### 5.8 Platform outputs

Purpose:

Future product repositories need stable outputs to consume.

Recommended outputs:

- raw bucket name
- artifacts bucket name
- logs bucket name
- CI/CD role ARN
- product deployment role ARN
- environment name
- AWS region

These outputs are important because they become the contract between platform and product repositories.

---

## 6. Proposed Data Platform Demo project structure

Recommended structure:

```text
data-platform-demo/
│
├── README.md
├── QUICKSTART.md
├── DEVELOPMENT_GUIDE.md
├── commands.md
│
├── .devcontainer/
│   ├── Dockerfile
│   ├── devcontainer.json
│   └── setup.sh
│
├── .github/
│   └── workflows/
│       ├── terraform-ci.yml
│       └── terraform-apply-dev.yml
│
├── terraform/
│   ├── bootstrap/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   └── versions.tf
│   │
│   ├── modules/
│   │   ├── storage/
│   │   ├── iam/
│   │   ├── secrets/
│   │   ├── logging/
│   │   └── networking/
│   │
│   ├── environments/
│   │   ├── dev/
│   │   │   ├── backend.hcl
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   ├── terraform.tfvars
│   │   │   └── versions.tf
│   │   │
│   │   ├── test/
│   │   │   └── README.md
│   │   │
│   │   └── prod/
│   │       └── README.md
│   │
│   └── examples/
│       └── product-integration/
│           └── README.md
│
├── docs/
│   ├── architecture.md
│   ├── platform-boundaries.md
│   ├── naming-and-tagging.md
│   ├── security-model.md
│   ├── future-roadmap.md
│   └── decisions/
│       ├── 0001-platform-vs-product-boundary.md
│       └── 0002-aws-first-platform-bootstrap.md
│
└── scripts/
    ├── bootstrap_backend.sh
    ├── plan_dev.sh
    └── apply_dev.sh
```

---

## 7. Why this structure is better than the current Terraform repo

The current Terraform repo has a good early idea, but the new structure improves it in these ways:

### Current repo

```text
bootstraps/
networking/
data_platform/
```

This is simple, but it can become difficult to scale because each folder is an independent root project.

### New repo

```text
terraform/bootstrap/
terraform/modules/
terraform/environments/dev/
```

This creates a cleaner pattern:

- `bootstrap` creates the backend
- `modules` contain reusable components
- `environments` compose modules into real environments

This is closer to how maintainable Terraform repositories are usually structured.

---

## 8. Recommended development sequence

Use this build order.

### Stage 1 — Repository skeleton

Create:

- README.md
- QUICKSTART.md
- DEVELOPMENT_GUIDE.md
- folder structure
- .gitignore
- .devcontainer

No Terraform resources yet except copied bootstrap structure.

### Stage 2 — Bootstrap backend

Move and clean the current `bootstraps/` code into:

```text
terraform/bootstrap/
```

Create:

- S3 state bucket
- DynamoDB lock table
- encryption
- versioning
- public access block

### Stage 3 — Storage module

Create module:

```text
terraform/modules/storage/
```

It should create:

- raw bucket
- artifacts bucket
- logs bucket
- bucket policies
- lifecycle rules
- outputs

### Stage 4 — IAM module

Create module:

```text
terraform/modules/iam/
```

It should create:

- platform admin role
- platform CI/CD role
- product deployment role

### Stage 5 — Logging module

Create module:

```text
terraform/modules/logging/
```

It should create:

- CloudWatch log groups
- basic metric alarms
- naming convention for future logs

### Stage 6 — Secrets module

Create module:

```text
terraform/modules/secrets/
```

It should create:

- placeholder secrets
- naming convention
- no committed secret values

### Stage 7 — Environment composition

Create:

```text
terraform/environments/dev/
```

This composes:

- networking module
- storage module
- iam module
- logging module
- secrets module

### Stage 8 — CI/CD

Document deployment role usage for:

- format
- validate
- plan
- controlled apply for dev

### Stage 9 — Documentation polish

Add:

- architecture.md
- security-model.md
- platform-boundaries.md
- future-roadmap.md

---

## 9. Suggested first version infrastructure boundary

For v1, build only this:

```text
Terraform backend
VPC networking baseline
Shared platform S3 storage
IAM roles
Secrets Manager placeholders
CloudWatch log groups
CI/CD deployment role
```

Do not build yet:

- Glue jobs
- Lambda ingestion
- Step Functions
- ECS
- EKS
- advanced networking
- Snowflake provisioning
- dbt projects
- Streamlit apps

Those should come later or live in product repositories.

---

## 10. How Data Product Demo should consume Data Platform Demo

The relationship should be:

```text
Data Platform Demo
        ↓ provides shared platform outputs
Data Product Demo
        ↓ creates product-specific Snowflake/dbt/Streamlit resources
Business data product
```

Example integration pattern:

1. Data Platform Demo creates shared buckets and IAM roles.
2. Data Product Demo receives platform outputs manually or via Terraform remote state.
3. Data Product Demo creates its own Snowflake database, schemas, warehouse, and stages.
4. Data Product Demo uses the platform-provided S3 locations for landing or external access.

---

## 11. Recommended naming convention

Use consistent names from the start.

Recommended pattern:

```text
<project>-<component>-<environment>-<account-suffix>
```

Examples:

```text
data-platform-demo-raw-dev-123456789012
data-platform-demo-artifacts-dev-123456789012
data-platform-demo-logs-dev-123456789012
```

Recommended tags:

```text
Project     = data-platform-demo
Environment = dev
Owner       = data-platform
ManagedBy   = terraform
Purpose     = platform-foundation
```

---

## 12. README positioning

The README should position the repository as:

> A reusable platform foundation for small-company data platforms.

Avoid describing it as only a Terraform repo.

Better wording:

> Data Platform Demo is a self-contained blueprint for bootstrapping the shared AWS foundation required by future data product repositories.

---

## 13. Final recommendation

Use the current Terraform repo as the seed, but restructure it before adding more resources.

The best path is:

1. Keep the bootstrap concept.
2. Move to a `terraform/bootstrap`, `terraform/modules`, `terraform/environments` structure.
3. Build only shared platform infrastructure in this repo.
4. Keep data-product-specific infrastructure in Data Product Demo.
5. Add strong documentation so this becomes a portfolio-grade platform blueprint.

This will give you two complementary repositories:

```text
Data Platform Demo  = shared platform foundation
Data Product Demo   = product implementation on top of the platform
```

Together, they represent the company idea clearly:

> reusable, production-minded data platform and data product blueprints for small organisations.
