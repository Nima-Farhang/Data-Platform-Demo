# Scripts

This folder contains helper scripts for working with the shared platform repository.

Typical uses include bootstrap helpers, validation helpers, and repeatable local or CI tasks related to shared infrastructure deployment.

Keep scripts here focused on platform operations. Product-specific automation belongs in the corresponding data product repository.


## Local Teardown

Destroy one environment while preserving the shared Terraform backend:

```bash
./scripts/destroy_environment.sh dev
```

After every environment has been destroyed, remove bootstrap and its state bucket:

```bash
./scripts/destroy_bootstrap.sh
```

To destroy `dev`, `test`, and `prod` in order and then bootstrap, use:

```bash
./scripts/destroy_all.sh
```

Each entry-point requires a typed confirmation. The scripts first save and apply a plan that enables S3 `force_destroy` only on the affected buckets, then save and apply the destroy plan. Normal deployments retain the safe default. Bootstrap is always destroyed last because it owns the remote state used by the environments.
