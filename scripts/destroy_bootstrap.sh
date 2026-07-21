#!/usr/bin/env bash
set -euo pipefail

# Destroy the remote-state backend and bootstrap IAM resources. Run this only
# after every platform environment has been destroyed.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_DIR="${REPO_ROOT}/terraform/bootstrap"
TFVARS_FILE="${BOOTSTRAP_DIR}/terraform.tfvars"
STATE_FILE="${BOOTSTRAP_DIR}/terraform.tfstate"

if [[ ! -f "${TFVARS_FILE}" ]]; then
  echo "Bootstrap variable file not found: ${TFVARS_FILE}"
  exit 1
fi

# Bootstrap intentionally uses local state. Without that state Terraform cannot
# safely determine which foundational resources it owns.
if [[ ! -f "${STATE_FILE}" ]]; then
  echo "Bootstrap state file not found: ${STATE_FILE}"
  echo "Refusing to destroy bootstrap resources without their Terraform state."
  exit 1
fi

if [[ "${DESTROY_AUTO_APPROVE:-false}" != "true" ]]; then
  echo
  echo "WARNING: This permanently destroys the Terraform state bucket, lock table,"
  echo "GitHub OIDC provider, and bootstrap deployment roles."
  echo "All environments must be destroyed first. State bucket contents cannot be recovered."
  echo
  read -r -p "Type 'DESTROY BOOTSTRAP AND STATE' to continue: " CONFIRMATION

  if [[ "${CONFIRMATION}" != "DESTROY BOOTSTRAP AND STATE" ]]; then
    echo "Confirmation did not match. Nothing was destroyed."
    exit 1
  fi
fi

cd "${BOOTSTRAP_DIR}"

terraform init

# Restore provider execute permissions when a mounted workspace strips them.
find .terraform/providers -type f -name 'terraform-provider-*' ! -perm -u=x -exec chmod u+x {} +

terraform fmt -check
terraform validate

# Record force_destroy in bootstrap state before entering destroy mode so the
# versioned state bucket can be emptied and deleted.
BUCKET_PLAN="$(mktemp "/tmp/data-platform-bootstrap-bucket.XXXXXX.tfplan")"
DESTROY_PLAN="$(mktemp "/tmp/data-platform-bootstrap-destroy.XXXXXX.tfplan")"
trap 'rm -f "${BUCKET_PLAN}" "${DESTROY_PLAN}"' EXIT

terraform plan \
  -target="aws_s3_bucket.terraform_state" \
  -var="force_destroy_buckets=true" \
  -out="${BUCKET_PLAN}"

terraform apply "${BUCKET_PLAN}"

terraform plan \
  -destroy \
  -var="force_destroy_buckets=true" \
  -out="${DESTROY_PLAN}"

terraform apply "${DESTROY_PLAN}"

echo
echo "Bootstrap resources and remote state were destroyed successfully."
