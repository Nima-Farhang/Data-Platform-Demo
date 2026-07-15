variable "project" {
  description = "Short project name used in IAM resource names."
  type        = string
  default     = "data-platform"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project))
    error_message = "Project must use lowercase letters, numbers, and hyphens only."
  }
}

variable "environment" {
  description = "Environment name used in IAM resource names."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "platform_bucket_arns" {
  description = "Map of shared platform S3 bucket ARNs by purpose."
  type        = map(string)
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

variable "platform_catalog_database_name" {
  description = "Optional name for the generic platform Glue database marker managed by the lakehouse foundation. Defaults to <project>_<environment>_platform."
  type        = string
  default     = null

  validation {
    condition     = var.platform_catalog_database_name == null || can(regex("^[a-z0-9_]+$", var.platform_catalog_database_name))
    error_message = "Platform catalog database name must use lowercase letters, numbers, and underscores only."
  }
}









variable "owner" {
  description = "Team or role responsible for IAM resources."
  type        = string
  default     = "Data Platform"
}

variable "cost_center" {
  description = "Cost allocation value for IAM resources."
  type        = string
  default     = "Demo"
}

variable "additional_tags" {
  description = "Additional tags to apply to IAM resources."
  type        = map(string)
  default     = {}
}

variable "product_glue_database_name_prefix" {
  description = "Glue database name prefix that product-owned Glue databases must use. Defaults to <project>_<environment>_."
  type        = string
  default     = null

  validation {
    condition     = var.product_glue_database_name_prefix == null || can(regex("^[a-z0-9_]+_$", var.product_glue_database_name_prefix))
    error_message = "Product Glue database name prefix must use lowercase letters, numbers, and underscores, and must end with an underscore."
  }
}
