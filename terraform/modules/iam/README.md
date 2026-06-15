# IAM Module

This module creates the V1 shared platform IAM baseline for Data Platform Demo.

It includes:

- Platform Admin Role
- CI/CD Deployment Role
- Product Deployment Role
- Optional GitHub Actions OIDC provider

The CI/CD deployment role can trust GitHub Actions through either an externally managed provider ARN (`github_oidc_provider_arn`) or a provider created by this module (`create_github_oidc_provider = true`). Configure least-privilege repository access with `github_organization`, `github_allowed_repositories`, `github_allowed_branches`, and `github_allowed_environments`. The older `github_repository_subjects` input is still supported for additional explicit subject patterns.

Product repository access remains controlled through the Product Deployment Role and its own trusted AWS principals.

Policies are scoped to V1 platform resource patterns and the shared platform S3 bucket ARNs passed into the module.
