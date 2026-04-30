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
ENVIRONMENT_DIR="${REPO_ROOT}/terraform/environments/${ENVIRONMENT_NAME}"
BACKEND_CONFIG="${ENVIRONMENT_DIR}/backend.hcl"

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

# Run Terraform from the selected environment root.
cd "${ENVIRONMENT_DIR}"

# Initialize Terraform using the environment-specific backend configuration.
terraform init -backend-config="${BACKEND_CONFIG}"

# Format the environment Terraform files.
terraform fmt

# Show the proposed infrastructure changes before applying them.
terraform plan

# Apply the planned changes. Terraform will prompt for confirmation unless
# auto-approve is added by a future CI/CD-specific wrapper.
terraform apply
