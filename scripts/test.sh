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

## confirm the variable is set
echo "Running tests for environment: ${ENVIRONMENT}"
echo "Running tests for environment: ${ENVIRONMENT_NAME}"
echo "Terraform directory: ${TERRAFORM_DIR}"
echo "Environment directory: ${ENVIRONMENT_DIR}"
echo "Backend config: ${BACKEND_CONFIG}"
echo "TFVAR file: ${TFVAR_FILE}"


