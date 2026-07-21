#!/usr/bin/env bash
set -euo pipefail

# Destroy every platform environment first, then destroy bootstrap last. The
# script stops immediately if any step fails, preserving the backend for retry.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENVIRONMENTS=(dev test prod)

echo
echo "WARNING: This permanently destroys all platform environments and bootstrap."
echo "Versioned platform data and all Terraform state will be deleted."
echo
read -r -p "Type 'DESTROY ALL' to continue: " CONFIRMATION

if [[ "${CONFIRMATION}" != "DESTROY ALL" ]]; then
  echo "Confirmation did not match. Nothing was destroyed."
  exit 1
fi

for ENVIRONMENT_NAME in "${ENVIRONMENTS[@]}"; do
  echo
  echo "Destroying environment: ${ENVIRONMENT_NAME}"
  DESTROY_AUTO_APPROVE=true "${REPO_ROOT}/scripts/destroy_environment.sh" "${ENVIRONMENT_NAME}"
done

echo
echo "All environments are gone. Destroying bootstrap last."
DESTROY_AUTO_APPROVE=true "${REPO_ROOT}/scripts/destroy_bootstrap.sh"

echo
echo "The complete data platform was destroyed successfully."
