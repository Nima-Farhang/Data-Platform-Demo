# IAM Module

This module creates the shared platform IAM baseline for Data Platform Demo environments.

It includes:

- Platform Admin Role
- Product Deployment Role
- Product deployment permission boundary

GitHub Actions OIDC provider and CI/CD deployment roles are intentionally managed by `terraform/bootstrap` because they must exist before environment pipelines can deploy the environment stacks.

Product repository access remains controlled through the Product Deployment Role and its own trusted AWS principals. The module also creates `product_deployment_permission_boundary_policy_arn`, a reusable permission boundary for product deployment roles. It is attached to the shared Product Deployment Role created here; product-specific roles should set `permissions_boundary` to the same ARN and grant only the product permissions they need.

The boundary permits product-owned Lambda functions, Glue jobs, EventBridge rules, API Gateway APIs, CloudWatch log groups, and product IAM roles that follow `product_resource_name_prefix` naming and tagging constraints. Shared platform resources are limited to required S3, log, and product secret actions. Explicit denies block privilege escalation paths, broad IAM administration, CloudTrail tampering, shared bucket deletion or administration, and platform KMS policy/key administration.

Policies are scoped to platform resource patterns and the shared platform S3 bucket ARNs passed into the module.
