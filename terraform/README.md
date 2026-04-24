# Terraform

This folder will contain Terraform for the shared platform infrastructure managed by this repository.

The structure separates bootstrap concerns, reusable modules, and environment compositions so the platform can be deployed consistently across `dev`, `test`, and `prod`.

This repository does not manage product-specific infrastructure. Any Terraform that exists only for one data product belongs in that product's repository.
