# IAM Module

This module creates the V1 shared platform IAM baseline for Data Platform Demo.

It includes:

- Platform Admin Role
- CI/CD Deployment Role
- Product Deployment Role
- Optional GitHub Actions OIDC provider

The CI/CD deployment role can trust GitHub Actions through either an externally managed provider ARN (`github_oidc_provider_arn`) or a provider created by this module (`create_github_oidc_provider = true`). Configure least-privilege repository access with `github_organization`, `github_allowed_repositories`, `github_allowed_branches`, and `github_allowed_environments`. The older `github_repository_subjects` input is still supported for additional explicit subject patterns.

Product repository access remains controlled through the Product Deployment Role and its own trusted AWS principals. The module also creates `product_deployment_permission_boundary_policy_arn`, a reusable permission boundary for product deployment roles. It is attached to the shared Product Deployment Role created here; product-specific roles should set `permissions_boundary` to the same ARN and grant only the product permissions they need.

The boundary permits product-owned Lambda functions, Glue jobs, EventBridge rules, API Gateway APIs, CloudWatch log groups, and product IAM roles that follow `product_resource_name_prefix` naming and tagging constraints. Shared platform resources are limited to required S3, log, and product secret actions. Explicit denies block privilege escalation paths, broad IAM administration, CloudTrail tampering, shared bucket deletion or administration, and platform KMS policy/key administration.

Policies are scoped to V1 platform resource patterns and the shared platform S3 bucket ARNs passed into the module.
