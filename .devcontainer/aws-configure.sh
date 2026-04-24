#!/bin/bash
set -e

AWS_CREDENTIALS_FILE="${HOME}/.aws/credentials"
mkdir -p "$(dirname "$AWS_CREDENTIALS_FILE")"

cat > "$AWS_CREDENTIALS_FILE" <<EOF
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
EOF

echo "AWS CLI credentials for account '${SANDPIT_ACCOUNT_ID}' configured at ${AWS_CREDENTIALS_FILE}."
cat $AWS_CREDENTIALS_FILE


AWS_CONFIG_FILE="${HOME}/.aws/config"
mkdir -p "$(dirname "$AWS_CONFIG_FILE")"

cat > "$AWS_CONFIG_FILE" <<EOF
[default]
region = ap-southeast-2
output = json
EOF

echo "AWS CLI configuration configured at ${AWS_CONFIG_FILE}."

cat $AWS_CONFIG_FILE