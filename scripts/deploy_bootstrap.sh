#!/usr/bin/env bash
set -euo pipefail

# Resolve paths from the script location so the command can be run from anywhere
# inside or outside the repository.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_DIR="${REPO_ROOT}/terraform/bootstrap"
TFVARS_FILE="${BOOTSTRAP_DIR}/terraform.tfvars"
STATE_FILE="${BOOTSTRAP_DIR}/terraform.tfstate"

# Read a simple string value from terraform.tfvars.
tfvars_value() {
  local name="$1"

  sed -nE "s/^${name}[[:space:]]*=[[:space:]]*\"([^\"]+)\".*/\1/p" "${TFVARS_FILE}" | head -n 1
}

# Read a Terraform expression from the initialized bootstrap root.
terraform_value() {
  local expression="$1"

  terraform console <<< "${expression}" | tr -d '"'
}

# Import an existing resource into local bootstrap state. Import failures are
# allowed because the resource may not exist yet; terraform apply can create it.
try_import() {
  local address="$1"
  local import_id="$2"

  echo "Attempting import: ${address} -> ${import_id}"

  if terraform state show "${address}" >/dev/null 2>&1; then
    echo "Already in state: ${address}"
    return 0
  fi

  if terraform import "${address}" "${import_id}"; then
    echo "Imported: ${address}"
  else
    echo "Import skipped or failed for ${address}; terraform apply will handle it if it does not exist."
  fi
}

# Confirm the bootstrap Terraform root exists.
if [[ ! -d "${BOOTSTRAP_DIR}" ]]; then
  echo "Terraform bootstrap directory not found: ${BOOTSTRAP_DIR}"
  exit 1
fi

# Confirm bootstrap variable values are available before trying to derive names.
if [[ ! -f "${TFVARS_FILE}" ]]; then
  echo "Bootstrap tfvars file not found: ${TFVARS_FILE}"
  exit 1
fi

cd "${BOOTSTRAP_DIR}"

# Initialize the bootstrap root. Bootstrap uses local state because it creates
# the remote state bucket and lock table used by environment deployments.
terraform init

# Some mounted development workspaces can preserve downloaded provider files
# without their executable bit. Terraform cannot load those providers until the
# permission is restored.
find .terraform/providers -type f -name 'terraform-provider-*' ! -perm -u=x -exec chmod u+x {} +

PROJECT="$(terraform_value "var.project")"
STATE_BUCKET_SUFFIX="$(tfvars_value "state_bucket_suffix")"
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text 2>/dev/null || true)"
DEPLOYMENT_ENVIRONMENTS="$(terraform_value 'join(",", var.deployment_environments)')"

if [[ -z "${PROJECT}" || -z "${STATE_BUCKET_SUFFIX}" ]]; then
  echo "Could not derive project or state_bucket_suffix for bootstrap imports."
  exit 1
fi

STATE_BUCKET_NAME="${PROJECT}-terraform-state-${STATE_BUCKET_SUFFIX}"
LOCK_TABLE_NAME="${PROJECT}-terraform-locks"

# If local bootstrap state is missing, try to rebuild backend state first.
if [[ -f "${STATE_FILE}" ]]; then
  echo "Bootstrap state file found: ${STATE_FILE}"
else
  echo "Bootstrap state file not found. Attempting to rebuild state from existing infrastructure."

  try_import "aws_s3_bucket.terraform_state" "${STATE_BUCKET_NAME}"
  try_import "aws_s3_bucket_server_side_encryption_configuration.terraform_state" "${STATE_BUCKET_NAME}"
  try_import "aws_s3_bucket_versioning.terraform_state" "${STATE_BUCKET_NAME}"
  try_import "aws_s3_bucket_public_access_block.terraform_state" "${STATE_BUCKET_NAME}"
  try_import "aws_s3_bucket_ownership_controls.terraform_state" "${STATE_BUCKET_NAME}"
  try_import "aws_dynamodb_table.terraform_locks" "${LOCK_TABLE_NAME}"
fi

# Bootstrap also owns the GitHub OIDC provider and per-environment GitHub
# deployment roles. Import them when they already exist, which supports both
# missing local state recovery and migration from older environment-owned roles.
if [[ -n "${AWS_ACCOUNT_ID}" ]]; then
  GITHUB_OIDC_PROVIDER_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
  try_import "aws_iam_openid_connect_provider.github" "${GITHUB_OIDC_PROVIDER_ARN}"
else
  echo "Could not determine AWS account ID; skipping GitHub OIDC provider import."
fi

IFS=',' read -r -a ENVIRONMENTS <<< "${DEPLOYMENT_ENVIRONMENTS}"
for ENVIRONMENT_NAME in "${ENVIRONMENTS[@]}"; do
  if [[ -z "${ENVIRONMENT_NAME}" ]]; then
    continue
  fi

  ROLE_NAME="${PROJECT}-${ENVIRONMENT_NAME}-cicd-deployment-role"
  POLICY_NAME="${PROJECT}-${ENVIRONMENT_NAME}-cicd-deployment-policy"

  try_import "aws_iam_role.github_deployment[\"${ENVIRONMENT_NAME}\"]" "${ROLE_NAME}"
  try_import "aws_iam_role_policy.github_deployment[\"${ENVIRONMENT_NAME}\"]" "${ROLE_NAME}:${POLICY_NAME}"
done

# Format the bootstrap Terraform files.
terraform fmt

# Show the proposed bootstrap changes before applying them.
terraform plan

# Apply bootstrap changes. Terraform will prompt for confirmation unless
# auto-approve is added by a future CI/CD-specific wrapper.
terraform apply
