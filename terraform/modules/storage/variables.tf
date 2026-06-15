variable "project" {
  description = "Short project name used in storage resource names."
  type        = string
  default     = "data-platform"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project))
    error_message = "Project must use lowercase letters, numbers, and hyphens only."
  }
}

variable "environment" {
  description = "Environment name used in storage resource names."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "account_suffix" {
  description = "Account-specific suffix used to make S3 bucket names globally unique."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_suffix))
    error_message = "Account suffix must be a 12-digit AWS account ID."
  }
}

variable "owner" {
  description = "Team or role responsible for the storage resources."
  type        = string
  default     = "Data Platform"
}

variable "cost_center" {
  description = "Cost allocation value for storage resources."
  type        = string
  default     = "Demo"
}

variable "additional_tags" {
  description = "Additional tags to apply to storage resources."
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN used for S3 bucket encryption. When null, buckets use AES256 managed encryption."
  type        = string
  default     = null
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days to retain noncurrent object versions in shared platform buckets."
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_version_expiration_days > 0
    error_message = "Noncurrent version expiration days must be greater than zero."
  }
}

variable "cloudtrail_log_prefix" {
  description = "S3 prefix in the logs bucket used for CloudTrail audit logs."
  type        = string
  default     = "cloudtrail"
}

variable "cloudtrail_log_expiration_days" {
  description = "Number of days to retain current CloudTrail audit log objects in the shared logs bucket."
  type        = number
  default     = 365

  validation {
    condition     = var.cloudtrail_log_expiration_days > 0
    error_message = "CloudTrail log expiration days must be greater than zero."
  }
}
