variable "aws_region" {
  description = "AWS region where bootstrap resources will be created."
  type        = string
  default     = "ap-southeast-2"
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

variable "state_bucket_suffix" {
  description = "Globally unique suffix for the Terraform state S3 bucket."
  type        = string
  default     = "210006516097"

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


variable "deployment_environments" {
  description = "Environment names that receive GitHub Actions CI/CD deployment roles during bootstrap."
  type        = list(string)
  default     = ["dev", "test", "prod"]

  validation {
    condition     = alltrue([for environment in var.deployment_environments : contains(["dev", "test", "prod"], environment)])
    error_message = "Deployment environments must contain only: dev, test, prod."
  }
}

variable "github_oidc_thumbprint_list" {
  description = "Thumbprints to configure on the GitHub Actions OIDC provider."
  type        = list(string)
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

variable "github_organization" {
  description = "GitHub organization or owner that contains repositories allowed to assume bootstrap deployment roles."
  type        = string
}

variable "github_allowed_repositories" {
  description = "Repository names in github_organization allowed to assume bootstrap deployment roles through GitHub Environments."
  type        = list(string)
}

variable "github_repository_subjects_by_environment" {
  description = "Additional explicit GitHub OIDC subject patterns allowed per environment. Prefer github_organization, github_allowed_repositories, and deployment_environments for normal use."
  type        = map(list(string))
  default     = {}
}
