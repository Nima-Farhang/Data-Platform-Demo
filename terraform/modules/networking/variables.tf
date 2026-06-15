variable "project" {
  description = "Short project name used in networking resource names."
  type        = string
  default     = "data-platform"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project))
    error_message = "Project must use lowercase letters, numbers, and hyphens only."
  }
}

variable "environment" {
  description = "Environment name used in networking resource names."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "vpc_cidr_block" {
  description = "CIDR block for the platform VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the private subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability Zone for the public and private subnets. Leave null to let AWS choose."
  type        = string
  default     = null
}

variable "owner" {
  description = "Team or role responsible for the networking resources."
  type        = string
  default     = "Data Platform"
}

variable "cost_center" {
  description = "Cost allocation value for networking resources."
  type        = string
  default     = "Demo"
}

variable "additional_tags" {
  description = "Additional tags to apply to networking resources."
  type        = map(string)
  default     = {}
}

variable "enable_vpc_endpoints" {
  description = "Whether to create optional VPC endpoints for private platform workloads. Disabled by default because interface endpoints add cost."
  type        = bool
  default     = false
}

variable "vpc_endpoint_services" {
  description = "VPC endpoint services to create when enable_vpc_endpoints is true. Supported values: s3, logs, secretsmanager, sts, glue, kms."
  type        = list(string)
  default     = ["s3", "logs", "secretsmanager", "sts", "glue", "kms"]

  validation {
    condition     = alltrue([for service in var.vpc_endpoint_services : contains(["s3", "logs", "secretsmanager", "sts", "glue", "kms"], service)])
    error_message = "VPC endpoint services must be one of: s3, logs, secretsmanager, sts, glue, kms."
  }
}
