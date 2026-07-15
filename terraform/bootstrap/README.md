# Bootstrap

This folder is reserved for Terraform that bootstraps shared platform prerequisites.

Typical bootstrap responsibilities include the remote Terraform state backend and other foundational resources needed before normal environment deployment can begin.

Only shared platform bootstrap infrastructure belongs here.

## Resources

This bootstrap layer creates:

- S3 bucket for Terraform remote state
- DynamoDB table for Terraform state locking
- S3 bucket server-side encryption
- DynamoDB server-side encryption
- S3 bucket versioning
- S3 public access blocking
- GitHub Actions OIDC provider
- GitHub Actions CI/CD deployment roles for `dev`, `test`, and `prod`
- Optional product-scoped GitHub Actions OIDC deployment roles for product repositories

It does not create networking resources or product workload resources.

Product-scoped deployment roles are intentionally separate from platform CI/CD deployment roles. They can access only configured product Terraform state-key patterns, use the shared lock table, read minimal identity metadata, and assume the environment product deployment role.

## Usage

Create a local variables file from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Update `state_bucket_suffix` to a globally unique lowercase suffix, then run:

```bash
terraform init -backend=false
terraform plan
terraform apply
```
