variable "project" {
  description = "Short project name used in KMS resource names."
  type        = string
  default     = "data-platform"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project))
    error_message = "Project must use lowercase letters, numbers, and hyphens only."
  }
}

variable "environment" {
  description = "Environment name used in KMS resource names."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "owner" {
  description = "Team or role responsible for the KMS key."
  type        = string
  default     = "Data Platform"
}

variable "cost_center" {
  description = "Cost allocation value for the KMS key."
  type        = string
  default     = "Demo"
}

variable "additional_tags" {
  description = "Additional tags to apply to the KMS key."
  type        = map(string)
  default     = {}
}
