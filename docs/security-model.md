# Security Model

The security model provides practical guardrails for the shared AWS platform foundation while keeping the repository understandable and reusable.

## Principles

- encrypt shared storage, logs, audit data, and state where supported
- use IAM roles instead of hardcoded users
- apply least privilege
- block public storage access
- keep real credentials out of source control
- separate platform and product responsibilities
- preserve auditability through account-level CloudTrail

## Identity and Access

The platform defines three role patterns:

- Platform Admin Role for controlled platform administration
- CI/CD Deployment Role for GitHub Actions based platform deployment
- Product Deployment Role for future product repository deployments

GitHub OIDC can be created by the platform or supplied externally. Trust policies should be scoped to approved repositories, branches, or environments.

## Product Permission Boundary

The product deployment permission boundary limits the maximum permissions product deployment roles can use. It blocks privilege escalation, broad IAM administration, CloudTrail tampering, shared bucket administration, and platform KMS administration.

Product repositories should attach the exported `product_deployment_permission_boundary_policy_arn` to product deployment roles they create.

## Data and State Protection

Platform S3 buckets and Terraform state storage must use encryption, versioning where appropriate, lifecycle controls, and public access blocking.

Terraform state can contain sensitive infrastructure metadata. Access should be limited to platform administrators and approved automation.

## Secrets

AWS Secrets Manager provides placeholder structure and naming conventions. Real secret values must not be committed in Terraform variable files, Markdown, scripts, workflow files, or application configuration.

Product repositories own product-specific secret values and rotation processes.

## Network Security

The baseline network includes VPC, public subnet, private subnet, internet gateway, and optional VPC endpoints for private access to shared AWS services. Cost-increasing endpoints remain disabled by default.

NAT Gateway, transit networking, multi-AZ expansion, and advanced network controls require an explicit platform scope decision.

## Audit and Monitoring

The platform includes account-level CloudTrail, log file validation, platform CloudWatch log groups, and basic platform alarms.

Product-specific alarms, dashboards, and workload telemetry belong in product repositories.

## Lakehouse Security

The platform defines Glue Catalog and lakehouse conventions. Product repositories own product databases, Iceberg tables, crawlers, jobs, table permissions, and business data models.

## Future Enhancements

Future reusable platform controls may include multi-account isolation, richer monitoring, cost anomaly detection, dedicated product key patterns, Lake Formation, or finer-grained catalog permissions. Add them only when they remain shared platform concerns.
