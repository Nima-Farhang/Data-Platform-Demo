variable "project" {
  description = "Short project name used in logging resource names."
  type        = string
  default     = "data-platform"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project))
    error_message = "Project must use lowercase letters, numbers, and hyphens only."
  }
}

variable "environment" {
  description = "Environment name used in logging resource names."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "log_group_retention_days" {
  description = "Default retention in days for platform CloudWatch log groups."
  type        = number
  default     = 90

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_group_retention_days)
    error_message = "Log group retention days must be a valid CloudWatch Logs retention value."
  }
}

variable "platform_log_group_retention_days" {
  description = "Optional per-platform-log-group retention overrides by key. Supported keys are platform, deployments, products."
  type        = map(number)
  default     = {}

  validation {
    condition     = alltrue([for days in values(var.platform_log_group_retention_days) : contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], days)])
    error_message = "Platform log group retention override values must be valid CloudWatch Logs retention values."
  }
}

variable "log_group_kms_key_arn" {
  description = "Optional KMS key ARN used to encrypt platform CloudWatch log groups."
  type        = string
  default     = null
}

variable "error_alarm_evaluation_periods" {
  description = "Number of periods used by platform error-count alarms."
  type        = number
  default     = 1

  validation {
    condition     = var.error_alarm_evaluation_periods > 0
    error_message = "Error alarm evaluation periods must be greater than zero."
  }
}

variable "error_alarm_period_seconds" {
  description = "Period in seconds used by platform error-count alarms."
  type        = number
  default     = 300

  validation {
    condition     = var.error_alarm_period_seconds > 0
    error_message = "Error alarm period seconds must be greater than zero."
  }
}

variable "error_alarm_threshold" {
  description = "Error count threshold for platform log error alarms."
  type        = number
  default     = 1

  validation {
    condition     = var.error_alarm_threshold > 0
    error_message = "Error alarm threshold must be greater than zero."
  }
}

variable "deployment_failure_alarm_threshold" {
  description = "Threshold for the platform deployment failure placeholder alarm."
  type        = number
  default     = 1

  validation {
    condition     = var.deployment_failure_alarm_threshold > 0
    error_message = "Deployment failure alarm threshold must be greater than zero."
  }
}

variable "alarm_actions" {
  description = "Optional alarm action ARNs for platform CloudWatch alarms."
  type        = list(string)
  default     = []
}

variable "owner" {
  description = "Team or role responsible for logging resources."
  type        = string
  default     = "Data Platform"
}

variable "cost_center" {
  description = "Cost allocation value for logging resources."
  type        = string
  default     = "Demo"
}

variable "additional_tags" {
  description = "Additional tags to apply to logging resources."
  type        = map(string)
  default     = {}
}
