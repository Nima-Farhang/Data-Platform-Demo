variable "project" {
  description = "Short project name used in lakehouse convention names."
  type        = string
  default     = "data-platform"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project))
    error_message = "Project must use lowercase letters, numbers, and hyphens only."
  }
}

variable "environment" {
  description = "Environment name used in lakehouse convention names."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "curated_bucket_name" {
  description = "Name of the shared curated platform S3 bucket used as the lakehouse storage root."
  type        = string
}

variable "curated_bucket_arn" {
  description = "ARN of the shared curated platform S3 bucket used as the lakehouse storage root."
  type        = string
}

variable "curated_bucket_prefix" {
  description = "Prefix inside the curated bucket reserved for Iceberg/lakehouse data."
  type        = string
  default     = "iceberg"

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9!_.*'()/-]*[A-Za-z0-9]$", var.curated_bucket_prefix)) && !startswith(var.curated_bucket_prefix, "/") && !endswith(var.curated_bucket_prefix, "/")
    error_message = "Curated bucket prefix must be a non-empty S3 prefix without leading or trailing slashes."
  }
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

variable "owner" {
  description = "Team or role responsible for lakehouse catalog foundation resources."
  type        = string
  default     = "Data Platform"
}

variable "cost_center" {
  description = "Cost allocation value for lakehouse catalog foundation resources."
  type        = string
  default     = "Demo"
}

variable "additional_tags" {
  description = "Additional tags to apply to lakehouse catalog resources."
  type        = map(string)
  default     = {}
}
