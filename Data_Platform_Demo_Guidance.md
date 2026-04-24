# Data Platform Demo — Repository Blueprint and Development Guidance

## 1. Purpose of the new repository

The new repository should be called:

```text
Data-Platform-Demo
```

Its purpose is to become a **self-contained blueprint for bootstrapping a reusable data platform**, similar in spirit to the existing `Data-Product-Demo`, but focused on the **platform foundation** rather than a single business-facing data product.

The positioning should be:

> A compact, production-minded data platform starter kit for small companies, built with Snowflake, Terraform, dbt, GitHub Actions, and a clean structure that can be extended by future data products.

This repository should not try to become a full enterprise platform. It should show the minimum serious foundation that a small company needs before multiple data products can be added safely.

---

## 2. What I observed in the existing Data Product Demo

The `Data-Product-Demo` repository has a strong and clear idea:

- It is self-contained.
- It has infrastructure, transformation, application, and CI/CD in one place.
- It demonstrates a data-product delivery pattern similar to a microservice.
- It is easy to understand for a reviewer or potential client.
- It focuses on one bounded business product rather than an entire enterprise platform.

Current major components:

```text
.devcontainer/                Local/Codespaces development environment
.github/workflows/            Terraform, dbt, and Streamlit CI/CD
TERRAFORM/                    Snowflake infrastructure
DBT/data_product_demo/        dbt project for the product
STREAMLIT/                    Snowflake Streamlit apps
QUICKSTART.md                 Fast-start guide
README.md                     Main project explanation
```

The key design principle is excellent:

> One repository contains everything needed to build, deploy, and explain one focused data product.

For the new `Data-Platform-Demo`, we should keep the same clarity and self-contained style, but change the scope from:

```text
one business data product
```

to:

```text
one reusable platform foundation that future data products can sit on
```

---

## 3. What I observed in the existing Data Platform Framework

The `Data-Platform-Framework` repository is valuable, but it is not currently a complete platform bootstrap repository.

It is mainly a **dbt framework and engineering standards repository**.

Current strengths:

- Reusable dbt macros
- Standard schema generation logic
- Query tagging
- Audit column helper
- Freshness testing helper
- Demo-safe sensitivity classification
- Structured documentation
- AI-assisted engineering workflow prompts
- Example data product consuming the shared utilities
- SQL linting and validation workflows

Current structure:

```text
.github/agents/               AI role prompts
.github/workflows/            Validation and linting
skills/                       AI task guidance
profiles/                     Example dbt profile
configs/docs                  Architecture and principles
data-platform-utils/          Reusable dbt macros and tests
data-product-demo/            Example dbt project using the utilities
```

This repository is strong as a **framework layer**, but less suitable as the complete foundation for the new `Data-Platform-Demo` because it does not currently include a Terraform-based infrastructure bootstrap.

The best way to use it is:

```text
Data-Platform-Framework = reusable dbt standards, macros, and engineering conventions
Data-Platform-Demo      = deployable platform foundation using Terraform + dbt + CI/CD
Data-Product-Demo       = example business data product built on top of a platform
```

---

## 4. Recommended relationship between the repositories

These repositories should have distinct responsibilities.

### Repository 1 — Data Platform Demo

Purpose:

> Bootstrap the shared platform foundation.

It should create:

- Snowflake platform database
- environment-specific schemas
- platform warehouses
- platform roles
- service users
- resource monitors
- governance metadata structures
- optional observability tables or views
- CI/CD for Terraform and platform dbt utilities

It should not create business-product-specific infrastructure.

### Repository 2 — Data Product Demo

Purpose:

> Demonstrate a single business data product built on top of the platform.

It can create:

- product-specific database or schemas
- product-specific warehouse if required
- product-specific service user
- product-specific dbt models
- product-specific Streamlit apps
- product-specific dashboards or marts

### Repository 3 — Data Platform Framework

Purpose:

> Provide reusable dbt utilities and engineering standards.

It can supply:

- macros
- tests
- schema naming logic
- audit columns
- query tags
- style guide
- model-building skills/prompts

Over time, some of this may be copied into or packaged for the `Data-Platform-Demo`, but it should not be confused with infrastructure provisioning.

---

## 5. Important boundary: platform infrastructure vs data product infrastructure

You explicitly noted an important rule:

> Infrastructure specific to a data product should be defined in the data product repository, not in the data platform framework.

I agree with this. The platform repository should only define shared capabilities.

### Platform-owned infrastructure

The platform demo should own:

- account-level or shared Snowflake roles
- shared warehouses
- shared databases/schemas used by many products
- shared logging/metadata areas
- shared service users
- resource monitors
- governance objects
- default grants and access patterns
- CI/CD foundation
- reusable dbt package or utilities

### Product-owned infrastructure

A data product repository should own:

- product database or product schemas
- product-specific warehouse where justified
- product-specific dbt service user
- product-specific Streamlit app schema/stage
- product-specific grants
- product-specific ingestion stages
- product-specific alerting objects
- product-specific data models

This separation is important because it prevents the platform repo from becoming a dumping ground for every product.

---

## 6. Basic infrastructure the Data Platform Demo should build

The first version should be deliberately modest but professional.

It should build enough infrastructure to prove that a small company can start with a clean platform foundation and add data products later.

### 6.1 Snowflake platform database

Recommended object:

```text
<ENVIRONMENT>_DATA_PLATFORM_DB
```

Example:

```text
DEV_DATA_PLATFORM_DB
PROD_DATA_PLATFORM_DB
```

Purpose:

- hold shared platform metadata
- hold governance/reference data
- hold operational logs or views
- hold reusable platform utility objects

Recommended schemas:

```text
CONFIG
GOVERNANCE
OBSERVABILITY
AUDIT
UTILS
```

Optional later schemas:

```text
SECURITY
REFERENCE
CONTROL
```

### 6.2 Snowflake warehouses

Start with two shared warehouses:

```text
<ENVIRONMENT>_PLATFORM_TRANSFORM_WH
<ENVIRONMENT>_PLATFORM_ADMIN_WH
```

Purpose:

- `PLATFORM_TRANSFORM_WH`: used by shared dbt/platform jobs
- `PLATFORM_ADMIN_WH`: used by Terraform/admin/platform operations where appropriate

Both should be small by default:

```text
XSMALL
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE
```

Later, you can add:

```text
<ENVIRONMENT>_INGESTION_WH
<ENVIRONMENT>_MONITORING_WH
```

But do not overbuild in version 1.

### 6.3 Resource monitor

Create a platform-level resource monitor:

```text
<ENVIRONMENT>_DATA_PLATFORM_RESOURCE_MONITOR
```

Purpose:

- demonstrate cost control
- avoid runaway demo costs
- show production-minded Snowflake management

Use a small default quota for demo purposes.

### 6.4 Roles

Create a simple but expandable RBAC structure.

Recommended roles:

```text
<ENVIRONMENT>_DATA_PLATFORM_ADMIN_ROLE
<ENVIRONMENT>_DATA_PLATFORM_ENGINEER_ROLE
<ENVIRONMENT>_DATA_PLATFORM_VIEWER_ROLE
<ENVIRONMENT>_DATA_PRODUCT_DEVELOPER_ROLE
```

Purpose:

- `ADMIN_ROLE`: owns/manages platform objects
- `ENGINEER_ROLE`: builds and manages platform dbt assets
- `VIEWER_ROLE`: read-only access to platform metadata/observability
- `DATA_PRODUCT_DEVELOPER_ROLE`: baseline role that future data product repos may inherit or be granted

Keep the role hierarchy simple in version 1.

### 6.5 Service users

Create only the service users needed by the platform demo.

Recommended:

```text
SVC_<ENVIRONMENT>_TERRAFORM_PLATFORM
SVC_<ENVIRONMENT>_DBT_PLATFORM
```

However, there is a practical Snowflake/Terraform consideration:

- the Terraform user may need to exist before Terraform can manage objects
- the repo can document how to create the bootstrap Terraform user manually
- Terraform can then manage downstream roles, grants, warehouses, databases, and dbt user

For the first implementation, it is acceptable to document the Terraform bootstrap user as a prerequisite rather than create it inside the same Terraform project.

### 6.6 Shared platform metadata tables

Create a small set of useful platform tables.

Recommended in `AUDIT` schema:

```text
DEPLOYMENT_RUN_LOG
DATA_PRODUCT_REGISTRY
```

Recommended in `GOVERNANCE` schema:

```text
DATA_CLASSIFICATION_POLICY
SENSITIVE_COLUMN_REGISTRY
```

Recommended in `OBSERVABILITY` schema:

```text
QUERY_COST_BY_TAG_VW
MODEL_RUN_HISTORY_VW
```

For version 1, these can be simple Snowflake tables/views created either by Terraform or dbt.

Recommendation:

- Terraform creates the database, schemas, warehouses, roles, users, and grants.
- dbt creates platform utility views/tables inside the platform database.

This keeps Terraform focused on infrastructure and dbt focused on SQL objects.

### 6.7 Default grants

The demo should show a basic pattern:

- platform admin role owns/manages platform database
- platform engineer can create and modify objects in selected schemas
- platform viewer can read observability/governance metadata
- dbt platform user uses platform engineer role

Do not use `ACCOUNTADMIN` in dbt profiles except as a temporary local demo shortcut. The repo should teach the correct pattern.

### 6.8 Remote Terraform state

Keep the same idea used in the existing Data Product Demo:

```text
backend-dev.hcl
backend-prod.hcl
environments/dev.tfvars
environments/prod.tfvars
```

Use S3 remote state if that is the chosen direction.

This aligns with your broader AWS/Snowflake platform story.

---

## 7. Recommended project structure

Recommended structure for the new repository:

```text
Data-Platform-Demo/
│
├── README.md
├── QUICKSTART.md
├── .gitignore
├── .editorconfig
│
├── .devcontainer/
│   ├── Dockerfile
│   ├── devcontainer.json
│   ├── requirements.txt
│   └── init.sh
│
├── .github/
│   └── workflows/
│       ├── terraform.yml
│       ├── dbt_platform.yml
│       └── sql_lint.yml
│
├── TERRAFORM/
│   ├── README.md
│   ├── commands.md
│   ├── versions.tf
│   ├── provider.tf
│   ├── backend.tf
│   ├── backend-dev.hcl
│   ├── backend-prod.hcl
│   ├── variables.tf
│   ├── outputs.tf
│   ├── main.tf
│   ├── locals.tf
│   ├── environments/
│   │   ├── dev.tfvars
│   │   └── prod.tfvars
│   └── modules/
│       ├── snowflake_database/
│       ├── snowflake_warehouse/
│       ├── snowflake_rbac/
│       └── snowflake_service_user/
│
├── DBT/
│   └── data_platform_demo/
│       ├── README.md
│       ├── dbt_project.yml
│       ├── packages.yml
│       ├── macros/
│       │   ├── generate_schema_name.sql
│       │   ├── set_query_tag.sql
│       │   └── add_audit_columns.sql
│       ├── models/
│       │   ├── governance/
│       │   │   ├── _governance_models.yml
│       │   │   ├── data_classification_policy.sql
│       │   │   └── sensitive_column_registry.sql
│       │   ├── observability/
│       │   │   ├── _observability_models.yml
│       │   │   ├── query_cost_by_tag.sql
│       │   │   └── model_run_history.sql
│       │   └── audit/
│       │       ├── _audit_models.yml
│       │       └── data_product_registry.sql
│       ├── seeds/
│       │   ├── seed_data_products.csv
│       │   └── seed_data_classification_policy.csv
│       ├── tests/
│       └── analyses/
│           └── platform_cost_review.sql
│
├── docs/
│   ├── architecture-overview.md
│   ├── platform-principles.md
│   ├── rbac-model.md
│   ├── adding-a-data-product.md
│   ├── environment-strategy.md
│   └── roadmap.md
│
└── profiles/
    ├── README.md
    └── profiles.example.yml
```

---

## 8. Why this structure works

### 8.1 It mirrors the Data Product Demo

The new repo keeps the same understandable pattern:

```text
TERRAFORM + DBT + CI/CD + docs + devcontainer
```

This makes it easy to explain in interviews, client conversations, and GitHub README material.

### 8.2 It separates platform and product responsibilities

The platform repo creates shared foundations.

The product repo creates product-specific assets.

This gives you a mature architecture story:

```text
Platform enables data products.
Data products do not mutate the platform foundation casually.
```

### 8.3 It is small enough to finish

The repo should not attempt:

- full data catalog implementation
- complex masking policies in version 1
- full data mesh governance
- full observability tooling
- multi-cloud support
- enterprise-grade RBAC complexity

The goal is a credible blueprint, not a never-ending platform.

---

## 9. Recommended implementation phases

### Phase 1 — Repository skeleton

Create the structure only.

Deliverables:

- README.md
- QUICKSTART.md
- docs
- empty Terraform structure
- empty dbt platform project
- devcontainer base
- GitHub workflow placeholders

Goal:

> A reviewer can understand the intention without any implementation yet.

### Phase 2 — Terraform foundation

Implement Terraform for:

- platform database
- platform schemas
- two warehouses
- resource monitor
- roles
- grants
- dbt service user
- outputs

Goal:

> `terraform plan` and `terraform apply` can stand up the shared Snowflake foundation.

### Phase 3 — dbt platform project

Implement dbt for:

- query tagging
- schema naming
- audit column macro
- seeded data product registry
- seeded classification policy
- observability views
- basic tests

Goal:

> `dbt build` creates useful platform metadata structures.

### Phase 4 — CI/CD

Add GitHub Actions for:

- Terraform fmt/validate/plan
- Terraform apply to prod on protected branch
- dbt compile/build/test
- SQL linting

Goal:

> The repo demonstrates professional engineering workflow.

### Phase 5 — Connect to Data Product Demo

Update documentation to show how a future data product connects to this platform.

Examples:

- which role a product dbt user should receive
- how product query tags should be structured
- how product metadata can be registered
- what infrastructure remains product-owned

Goal:

> The platform demo and product demo tell one coherent story.

---

## 10. Suggested README positioning

The README should say something like:

```markdown
# Data Platform Demo

A self-contained blueprint for bootstrapping a small-company data platform using Snowflake, Terraform, dbt, and GitHub Actions.

This repository demonstrates the shared foundation that future data products can build on top of: databases, schemas, warehouses, roles, service users, governance metadata, observability views, and CI/CD automation.

It is intentionally compact. The goal is not to replicate a large enterprise platform, but to show a clean, repeatable, production-minded starting point for growing companies.
```

Avoid positioning it as a consultancy demo only. Position it as a reusable engineering product.

---

## 11. Recommended Snowflake naming convention

Use consistent object names.

```text
<ENVIRONMENT>_DATA_PLATFORM_DB
<ENVIRONMENT>_PLATFORM_TRANSFORM_WH
<ENVIRONMENT>_PLATFORM_ADMIN_WH
<ENVIRONMENT>_DATA_PLATFORM_RESOURCE_MONITOR
<ENVIRONMENT>_DATA_PLATFORM_ADMIN_ROLE
<ENVIRONMENT>_DATA_PLATFORM_ENGINEER_ROLE
<ENVIRONMENT>_DATA_PLATFORM_VIEWER_ROLE
SVC_<ENVIRONMENT>_DBT_PLATFORM
```

Example for production:

```text
PROD_DATA_PLATFORM_DB
PROD_PLATFORM_TRANSFORM_WH
PROD_PLATFORM_ADMIN_WH
PROD_DATA_PLATFORM_RESOURCE_MONITOR
PROD_DATA_PLATFORM_ADMIN_ROLE
PROD_DATA_PLATFORM_ENGINEER_ROLE
PROD_DATA_PLATFORM_VIEWER_ROLE
SVC_PROD_DBT_PLATFORM
```

---

## 12. Recommended Terraform design

Keep Terraform modular, but do not over-engineer.

Use modules only where repetition is likely:

```text
modules/snowflake_database
modules/snowflake_warehouse
modules/snowflake_rbac
modules/snowflake_service_user
```

Do not create too many tiny modules in version 1.

The top-level `main.tf` should remain readable enough that a reviewer can understand the full platform foundation quickly.

Recommended Terraform responsibilities:

- providers
- backend
- database
- schemas
- warehouses
- resource monitors
- roles
- grants
- dbt service user
- outputs

Avoid using Terraform for:

- detailed dbt SQL models
- seed data
- complex observability SQL
- frequently changing business metadata

Those belong in dbt.

---

## 13. Recommended dbt platform design

The dbt project should be small but useful.

Recommended dbt layers:

```text
models/governance
models/observability
models/audit
```

### Governance examples

```text
data_classification_policy.sql
sensitive_column_registry.sql
```

Purpose:

- define simple classification patterns
- show how sensitive data can be registered or reviewed

### Observability examples

```text
query_cost_by_tag.sql
model_run_history.sql
```

Purpose:

- show query cost attribution
- show model execution visibility
- support platform cost review

### Audit examples

```text
data_product_registry.sql
```

Purpose:

- register future data products
- track owner, product name, domain, criticality, and repository link

---

## 14. Suggested seed files

Use seeds to keep the first implementation simple.

### seed_data_products.csv

Columns:

```text
data_product_name,domain,owner,repository_url,criticality,status
```

Example rows:

```text
customer_insights,commercial,example_owner,https://github.com/example/customer-insights,medium,active
service_operations,operations,example_owner,https://github.com/example/service-operations,medium,active
```

### seed_data_classification_policy.csv

Columns:

```text
classification,description,example_columns,handling_guidance
```

Example classifications:

```text
PUBLIC
INTERNAL
CONFIDENTIAL
RESTRICTED
```

This is simple but gives the repo a governance story.

---

## 15. CI/CD guidance

Create three workflows.

### terraform.yml

Purpose:

- run `terraform fmt`
- run `terraform init`
- run `terraform validate`
- run `terraform plan`
- apply only on protected branch/environment

### dbt_platform.yml

Purpose:

- install dbt
- create temporary dbt profile from GitHub Secrets
- run `dbt deps`
- run `dbt compile`
- run `dbt build`

### sql_lint.yml

Purpose:

- run SQLFluff against dbt models/macros/tests
- enforce basic SQL discipline

Keep workflows simple and understandable.

---

## 16. GitHub Secrets to document

Document these expected secrets:

```text
SNOWFLAKE_ACCOUNT
SNOWFLAKE_ORGANIZATION_NAME
SNOWFLAKE_ACCOUNT_NAME
SNOWFLAKE_TERRAFORM_USER
SNOWFLAKE_TERRAFORM_PASS
DBT_PLATFORM_PASS
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

If using key-pair auth later, add it as a future improvement. For version 1, password-based demo auth is acceptable if clearly marked as demo/simple setup.

---

## 17. What not to include in version 1

Do not include these yet:

- AWS Glue ingestion framework
- Iceberg table management
- Kafka ingestion
- full masking policy automation
- complex data catalog
- OpenMetadata/DataHub integration
- Kubernetes
- full multi-account Snowflake deployment
- complicated data mesh ownership model

Those can be roadmap items.

Version 1 should be clean, finished, and explainable.

---

## 18. Roadmap ideas

After version 1, useful extensions include:

### Version 2

- masking policy demo
- row access policy demo
- more complete role hierarchy
- query tag cost dashboard
- Streamlit admin app for platform metadata

### Version 3

- AWS S3 ingestion landing zone
- Snowpipe or external stage examples
- Iceberg integration pattern
- product onboarding automation

### Version 4

- data quality monitoring
- metadata catalog integration
- automated lineage documentation
- cost anomaly detection

---

## 19. How this supports the company idea

This repository is commercially useful because it shows that your future company does not just sell time.

It sells a repeatable platform foundation.

The business story becomes:

> We help growing companies move from spreadsheet/reporting chaos to a governed, reliable, extensible data platform foundation. We use a proven blueprint, then add business-specific data products on top.

This is stronger than saying:

> I provide data consulting.

The repository becomes a proof asset for:

- interviews
- recruiters
- clients
- future consulting/productized service work
- technical credibility
- architecture storytelling

---

## 20. Recommended Cloud Code / AI development instruction

When you start building this in Cloud Code, use the following instruction:

```text
You are helping me build a new repository called Data-Platform-Demo.

The goal is to create a self-contained blueprint for bootstrapping a small-company data platform using Snowflake, Terraform, dbt, GitHub Actions, and GitHub Codespaces.

This repository should be similar in structure and clarity to my existing Data-Product-Demo repository, but the purpose is different:

- Data-Product-Demo demonstrates one business-facing data product.
- Data-Platform-Demo demonstrates the shared data platform foundation that future data products can use.

Important boundary:

- Platform-level infrastructure belongs in this repository.
- Data-product-specific infrastructure belongs in each data product repository.

Build the repository incrementally.

Start with the skeleton, documentation, Terraform structure, dbt platform project structure, and CI/CD placeholders. Do not over-engineer. The repository should be easy to understand, easy to run, and suitable as a professional portfolio/demo asset.

Use these main folders:

- .devcontainer/
- .github/workflows/
- TERRAFORM/
- DBT/data_platform_demo/
- docs/
- profiles/

The first infrastructure scope should include:

- Snowflake platform database
- schemas: CONFIG, GOVERNANCE, OBSERVABILITY, AUDIT, UTILS
- warehouses: PLATFORM_TRANSFORM_WH and PLATFORM_ADMIN_WH
- resource monitor
- platform roles
- dbt platform service user
- basic grants
- environment-specific tfvars for dev and prod

The first dbt scope should include:

- schema naming macro
- query tagging macro
- audit column macro
- governance seed/model examples
- observability views
- data product registry seed/model
- basic tests

Keep the code clean, explicit, and professional. Prefer descriptive variable names over abbreviations. Do not add fake enterprise complexity.
```

---

## 21. Final recommendation

Create `Data-Platform-Demo` as a clean, deployable platform foundation repository.

Use the `Data-Product-Demo` as the style and delivery reference.

Use the `Data-Platform-Framework` as the source of reusable dbt standards and macro ideas.

Do not merge all ideas into one giant repository.

The clean story should be:

```text
Data-Platform-Demo  -> creates the shared foundation
Data-Product-Demo   -> demonstrates one product built on that foundation
Framework utilities -> standardise how dbt products are built
```

This is the right architecture story for your future company idea.
