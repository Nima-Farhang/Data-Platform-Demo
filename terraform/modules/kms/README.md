# KMS Module

This module creates a shared platform KMS key and alias for the Data Platform Demo environment.

## Resources

- `aws_kms_key.platform`
- `aws_kms_alias.platform`

## Inputs

- `project`
- `environment`
- `owner`
- `cost_center`
- `additional_tags`

## Outputs

- `key_id`
- `key_arn`
- `alias_name`
- `alias_arn`
