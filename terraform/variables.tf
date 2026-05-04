variable "aws_region" {
  description = "AWS region where dev platform resources will be created."
  type        = string
  default     = "ap-southeast-2"
}

variable "project" {
  description = "Short project name used in dev resource names."
  type        = string
  default     = "data-platform"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project))
    error_message = "Project must use lowercase letters, numbers, and hyphens only."
  }
}

variable "environment" {
  description = "Environment name for this platform deployment."
  type        = string
  default     = "dev"

  validation {
    condition     = var.environment == "dev"
    error_message = "This environment root is only for dev."
  }
}

variable "vpc_cidr_block" {
  description = "CIDR block for the dev platform VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the dev public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the dev private subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability Zone for the dev public and private subnets. Leave null to let AWS choose."
  type        = string
  default     = null
}

variable "account_suffix" {
  description = "Account-specific suffix used to make dev S3 bucket names globally unique."
  type        = string
  default     = "210006516097"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_suffix))
    error_message = "Account suffix must be a 12-digit AWS account ID."
  }
}

variable "owner" {
  description = "Team or role responsible for dev platform resources."
  type        = string
  default     = "Data Platform"
}

variable "cost_center" {
  description = "Cost allocation value for dev platform resources."
  type        = string
  default     = "Demo"
}

variable "additional_tags" {
  description = "Additional tags to apply to dev platform resources."
  type        = map(string)
  default     = {}
}
