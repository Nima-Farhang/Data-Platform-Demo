#!/usr/bin/env bash
set -euo pipefail

# Destroy one platform environment while keeping the bootstrap backend intact.
# The bootstrap must remain available until every environment has been removed.
ENVIRONMENT_NAME="${1:-${ENVIRONMENT:-}}"

if [[ -z "${ENVIRONMENT_NAME}" ]]; then
  echo "Usage: ./scripts/destroy_environment.sh <dev|test|prod>"
  exit 1
fi

case "${ENVIRONMENT_NAME}" in
  dev|test|prod) ;;
  *)
    echo "Invalid environment: ${ENVIRONMENT_NAME}"
    echo "Expected one of: dev, test, prod"
    exit 1
    ;;
esac

# Resolve paths from the script location so the script works from any directory.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="${REPO_ROOT}/terraform"
ENVIRONMENT_DIR="${TERRAFORM_DIR}/environments/${ENVIRONMENT_NAME}"
BACKEND_CONFIG="${ENVIRONMENT_DIR}/backend-${ENVIRONMENT_NAME}.hcl"
TFVAR_FILE="${ENVIRONMENT_DIR}/${ENVIRONMENT_NAME}.tfvars"

if [[ ! -f "${BACKEND_CONFIG}" || ! -f "${TFVAR_FILE}" ]]; then
  echo "Terraform configuration is incomplete for environment: ${ENVIRONMENT_NAME}"
  exit 1
fi

# destroy_all.sh performs one confirmation for the complete teardown and then
# uses DESTROY_AUTO_APPROVE=true for its child scripts.
if [[ "${DESTROY_AUTO_APPROVE:-false}" != "true" ]]; then
  echo
  echo "WARNING: This permanently destroys the ${ENVIRONMENT_NAME} platform environment."
  echo "Versioned objects in its platform buckets will also be deleted."
  echo
  read -r -p "Type 'DESTROY ${ENVIRONMENT_NAME}' to continue: " CONFIRMATION

  if [[ "${CONFIRMATION}" != "DESTROY ${ENVIRONMENT_NAME}" ]]; then
    echo "Confirmation did not match. Nothing was destroyed."
    exit 1
  fi
fi

cd "${TERRAFORM_DIR}"

# Connect to this environment's remote state before creating the destroy plan.
terraform init -reconfigure -backend-config="${BACKEND_CONFIG}"

# Restore provider execute permissions when a mounted workspace strips them.
find .terraform/providers -type f -name 'terraform-provider-*' ! -perm -u=x -exec chmod u+x {} +

terraform fmt -check -recursive
terraform validate

# Record force_destroy on the bucket resources before entering destroy mode.
# Targeting only the buckets avoids applying unrelated pending changes.
BUCKET_PLAN="$(mktemp "/tmp/data-platform-${ENVIRONMENT_NAME}-buckets.XXXXXX.tfplan")"
DESTROY_PLAN="$(mktemp "/tmp/data-platform-${ENVIRONMENT_NAME}-destroy.XXXXXX.tfplan")"
trap 'rm -f "${BUCKET_PLAN}" "${DESTROY_PLAN}"' EXIT

terraform plan \
  -target="module.storage.aws_s3_bucket.platform" \
  -var-file="${TFVAR_FILE}" \
  -var="force_destroy_buckets=true" \
  -out="${BUCKET_PLAN}"

terraform apply "${BUCKET_PLAN}"

# A saved destroy plan ensures Terraform applies exactly what was reviewed.
terraform plan \
  -destroy \
  -var-file="${TFVAR_FILE}" \
  -var="force_destroy_buckets=true" \
  -out="${DESTROY_PLAN}"

terraform apply "${DESTROY_PLAN}"

echo
echo "Environment '${ENVIRONMENT_NAME}' was destroyed successfully."
