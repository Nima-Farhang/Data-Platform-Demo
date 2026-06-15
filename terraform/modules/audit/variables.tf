variable "project" {
  description = "Short project name used in audit resource names."
  type        = string
  default     = "data-platform"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project))
    error_message = "Project must use lowercase letters, numbers, and hyphens only."
  }
}

variable "environment" {
  description = "Environment name used in audit resource names."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "logs_bucket_name" {
  description = "Name of the platform logs bucket used for CloudTrail delivery."
  type        = string
}

variable "logs_bucket_arn" {
  description = "ARN of the platform logs bucket used for CloudTrail delivery."
  type        = string
}

variable "cloudtrail_log_prefix" {
  description = "S3 prefix inside the logs bucket where CloudTrail writes audit logs."
  type        = string
  default     = "cloudtrail"

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9!_.*'()/-]*[A-Za-z0-9]$", var.cloudtrail_log_prefix)) && !startswith(var.cloudtrail_log_prefix, "/") && !endswith(var.cloudtrail_log_prefix, "/")
    error_message = "CloudTrail log prefix must be a non-empty S3 prefix without leading or trailing slashes."
  }
}

variable "kms_key_arn" {
  description = "Optional platform KMS key ARN used to encrypt CloudTrail logs."
  type        = string
  default     = null
}

variable "is_multi_region_trail" {
  description = "Whether the account-level trail records events from all regions."
  type        = bool
  default     = true
}

variable "include_global_service_events" {
  description = "Whether the trail records global service events such as IAM."
  type        = bool
  default     = true
}

variable "owner" {
  description = "Team or role responsible for audit resources."
  type        = string
  default     = "Data Platform"
}

variable "cost_center" {
  description = "Cost allocation value for audit resources."
  type        = string
  default     = "Demo"
}

variable "additional_tags" {
  description = "Additional tags to apply to audit resources."
  type        = map(string)
  default     = {}
}
