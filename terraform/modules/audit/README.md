# Audit Module

This module creates the platform account-level CloudTrail baseline for one environment/account.

It writes management events to the existing platform logs bucket under `cloudtrail_log_prefix`, enables log file validation, and uses the platform KMS key when a key ARN is provided. It does not create product-specific trails.
