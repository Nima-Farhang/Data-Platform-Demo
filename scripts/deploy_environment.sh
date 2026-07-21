#!/usr/bin/env bash
set -euo pipefail

# Use the first script argument when provided, otherwise fall back to the
# ENVIRONMENT variable. This keeps the script useful locally and in CI/CD.
ENVIRONMENT_NAME="${1:-${ENVIRONMENT:-}}"

# Stop early if no environment was provided.
if [[ -z "${ENVIRONMENT_NAME}" ]]; then
  echo "Usage: ENVIRONMENT=<environment> ./scripts/deploy_environment.sh"
  echo "   or: ./scripts/deploy_environment.sh <environment>"
  exit 1
fi

# Resolve paths from the script location so the command can be run from anywhere
# inside or outside the repository.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="${REPO_ROOT}/terraform"
ENVIRONMENT_DIR="${TERRAFORM_DIR}/environments/${ENVIRONMENT_NAME}"
BACKEND_CONFIG="${ENVIRONMENT_DIR}/backend-${ENVIRONMENT_NAME}.hcl"
TFVAR_FILE="${ENVIRONMENT_DIR}/${ENVIRONMENT_NAME}.tfvars"

# Confirm the requested Terraform environment exists.
if [[ ! -d "${ENVIRONMENT_DIR}" ]]; then
  echo "Terraform environment directory not found: ${ENVIRONMENT_DIR}"
  exit 1
fi

# Confirm the environment has a backend configuration file for remote state.
if [[ ! -f "${BACKEND_CONFIG}" ]]; then
  echo "Terraform backend config not found: ${BACKEND_CONFIG}"
  exit 1
fi

# Confirm the tfvar exists for environment-specific inputs.
if [[ ! -f "${TFVAR_FILE}" ]]; then
  echo "Terraform tfvars file not found: ${TFVAR_FILE}"
  exit 1
fi

# Run Terraform from the selected environment root.
cd "${TERRAFORM_DIR}"

# Initialize Terraform using the environment-specific backend configuration.
terraform init -reconfigure -backend-config="${BACKEND_CONFIG}"

# Some mounted development workspaces can preserve downloaded provider files
# without their executable bit. Terraform cannot load those providers until the
# permission is restored.
find .terraform/providers -type f -name 'terraform-provider-*' ! -perm -u=x -exec chmod u+x {} +

# Format Terraform files.
terraform fmt -recursive

# Validate the composed platform configuration.
terraform validate

# Show the proposed infrastructure changes before applying them.
terraform plan -var-file="${TFVAR_FILE}"

# Apply the planned changes. CI/CD sets APPLY_APPROVE=true after the workflow
# has passed any required GitHub Environment approvals.
if [[ "${APPLY_APPROVE:-false}" == "true" ]]; then
  terraform apply -auto-approve -var-file="${TFVAR_FILE}"
else
  terraform apply -var-file="${TFVAR_FILE}"
fi
