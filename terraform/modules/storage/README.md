# Storage Module

This module creates the V1 shared platform S3 storage baseline for Data Platform Demo.

It includes only:

- Raw bucket
- Logs bucket
- Artifacts bucket
- Curated bucket

Each bucket has server-side encryption, versioning, lifecycle configuration, and public access blocking enabled.

By default, buckets use AES256 managed encryption. Pass `kms_key_arn` to use the shared platform KMS key.
