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

variable "product_terraform_state_key_patterns" {
  description = "Terraform state key patterns product-scoped GitHub OIDC roles may access. Use <environment> as the environment placeholder."
  type        = list(string)
  default = [
    "environments/<environment>/products/*/*.tfstate"
  ]

  validation {
    condition = alltrue([
      for pattern in var.product_terraform_state_key_patterns : startswith(pattern, "environments/<environment>/products/") && endswith(pattern, ".tfstate")
    ])
    error_message = "Product Terraform state key patterns must start with environments/<environment>/products/ and end with .tfstate."
  }
}
