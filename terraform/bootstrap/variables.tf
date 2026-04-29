variable "aws_region" {
  description = "AWS region where bootstrap resources will be created."
  type        = string
  default     = "eu-west-2"
}

variable "project" {
  description = "Short project name used in bootstrap resource names."
  type        = string
  default     = "data-platform"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project))
    error_message = "Project must use lowercase letters, numbers, and hyphens only."
  }
}

variable "environment" {
  description = "Environment name used in bootstrap resource names."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "state_bucket_suffix" {
  description = "Globally unique suffix for the Terraform state S3 bucket."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.state_bucket_suffix))
    error_message = "State bucket suffix must use lowercase letters, numbers, and hyphens only."
  }
}

variable "owner" {
  description = "Team or role responsible for the bootstrap resources."
  type        = string
  default     = "Data Platform"
}

variable "cost_center" {
  description = "Cost allocation value for bootstrap resources."
  type        = string
  default     = "Demo"
}

variable "additional_tags" {
  description = "Additional tags to apply to bootstrap resources."
  type        = map(string)
  default     = {}
}
