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

variable "product_resource_name_prefix" {
  description = "Name prefix that product-owned resources must use when controlled by the product deployment permission boundary. Defaults to <project>-<environment>-product-."
  type        = string
  default     = null

  validation {
    condition     = var.product_resource_name_prefix == null || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]*-$", var.product_resource_name_prefix))
    error_message = "Product resource name prefix must start with an alphanumeric character, may contain letters, numbers, hyphens, and underscores, and must end with a hyphen."
  }
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

variable "cloudtrail_log_prefix" {
  description = "S3 prefix in the platform logs bucket used for CloudTrail audit logs."
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

variable "cloudtrail_is_multi_region_trail" {
  description = "Whether the account-level CloudTrail trail records events from all regions."
  type        = bool
  default     = true
}

variable "cloudtrail_include_global_service_events" {
  description = "Whether the account-level CloudTrail trail records global service events such as IAM."
  type        = bool
  default     = true
}

variable "platform_log_group_retention_days" {
  description = "Default retention in days for platform CloudWatch log groups."
  type        = number
  default     = 90

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.platform_log_group_retention_days)
    error_message = "Platform log group retention days must be a valid CloudWatch Logs retention value."
  }
}

variable "platform_log_group_retention_overrides" {
  description = "Optional retention overrides for platform log groups by key. Supported keys are platform, deployments, products."
  type        = map(number)
  default     = {}

  validation {
    condition     = alltrue([for days in values(var.platform_log_group_retention_overrides) : contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], days)])
    error_message = "Platform log group retention override values must be valid CloudWatch Logs retention values."
  }
}

variable "platform_logging_alarm_actions" {
  description = "Optional alarm action ARNs for platform logging CloudWatch alarms."
  type        = list(string)
  default     = []
}

variable "lakehouse_curated_bucket_prefix" {
  description = "Prefix inside the curated bucket reserved for Iceberg/lakehouse data."
  type        = string
  default     = "iceberg"
}

variable "create_platform_catalog_database" {
  description = "Whether to create a generic platform Glue database marker for the environment catalog."
  type        = bool
  default     = true
}

variable "platform_catalog_database_name" {
  description = "Optional name for the generic platform Glue database marker. Defaults to <project>_<environment>_platform."
  type        = string
  default     = null

  validation {
    condition     = var.platform_catalog_database_name == null || can(regex("^[a-z0-9_]+$", var.platform_catalog_database_name))
    error_message = "Platform catalog database name must use lowercase letters, numbers, and underscores only."
  }
}

variable "product_database_name_pattern" {
  description = "Naming convention product repositories should use for Glue databases."
  type        = string
  default     = "<project>_<environment>_<product>"
}

variable "product_table_location_pattern" {
  description = "S3 location convention product repositories should use for Iceberg table roots."
  type        = string
  default     = "s3://<curated-bucket>/<curated-prefix>/products/<product>/<database>/<table>/"
}
