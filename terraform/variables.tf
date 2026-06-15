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
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
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

variable "platform_admin_principal_arns" {
  description = "AWS principal ARNs allowed to assume the Platform Admin role. Defaults to the current account root."
  type        = list(string)
  default     = []
}

variable "product_deployment_principal_arns" {
  description = "AWS principal ARNs allowed to assume the Product Deployment role. Defaults to the current account root."
  type        = list(string)
  default     = []
}

variable "github_oidc_provider_arn" {
  description = "Optional externally managed GitHub Actions OIDC provider ARN allowed to assume the CI/CD role. Leave null when create_github_oidc_provider is true."
  type        = string
  default     = null
}

variable "create_github_oidc_provider" {
  description = "Whether to create the GitHub Actions OIDC provider in this account."
  type        = bool
  default     = false
}

variable "github_oidc_thumbprint_list" {
  description = "Thumbprints to configure on the GitHub Actions OIDC provider when this deployment creates it."
  type        = list(string)
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

variable "github_organization" {
  description = "GitHub organization or owner that contains the platform deployment repositories."
  type        = string
  default     = null
}

variable "github_allowed_repositories" {
  description = "Repository names in github_organization allowed to assume the CI/CD deployment role."
  type        = list(string)
  default     = []
}

variable "github_allowed_branches" {
  description = "Branch names allowed to assume the CI/CD deployment role."
  type        = list(string)
  default     = []
}

variable "github_allowed_environments" {
  description = "GitHub Environment names allowed to assume the CI/CD deployment role."
  type        = list(string)
  default     = []
}

variable "github_repository_subjects" {
  description = "Additional GitHub OIDC subject patterns allowed to assume the CI/CD role, for example repo:owner/repo:ref:refs/heads/main. Prefer github_organization, github_allowed_repositories, github_allowed_branches, and github_allowed_environments for new configuration."
  type        = list(string)
  default     = []
}
