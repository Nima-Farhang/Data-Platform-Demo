locals {
  common_tags = merge(
    {
      Project     = "Data Platform Demo"
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )
}

module "networking" {
  source = "./modules/networking"

  project                   = var.project
  environment               = var.environment
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block
  availability_zone         = var.availability_zone
  enable_vpc_endpoints      = var.enable_vpc_endpoints
  vpc_endpoint_services     = var.vpc_endpoint_services
  owner                     = var.owner
  cost_center               = var.cost_center
  additional_tags           = var.additional_tags
}

module "storage" {
  source = "./modules/storage"

  project                        = var.project
  environment                    = var.environment
  account_suffix                 = var.account_suffix
  kms_key_arn                    = module.kms.key_arn
  cloudtrail_log_prefix          = var.cloudtrail_log_prefix
  cloudtrail_log_expiration_days = var.cloudtrail_log_expiration_days
  owner                          = var.owner
  cost_center                    = var.cost_center
  additional_tags                = var.additional_tags
}

module "iam" {
  source = "./modules/iam"

  project                           = var.project
  environment                       = var.environment
  platform_bucket_arns              = module.storage.bucket_arns
  platform_admin_principal_arns     = var.platform_admin_principal_arns
  product_deployment_principal_arns = var.product_deployment_principal_arns
  product_resource_name_prefix      = var.product_resource_name_prefix
  platform_catalog_database_name    = var.platform_catalog_database_name
  github_oidc_provider_arn          = var.github_oidc_provider_arn
  create_github_oidc_provider       = var.create_github_oidc_provider
  github_oidc_thumbprint_list       = var.github_oidc_thumbprint_list
  github_organization               = var.github_organization
  github_allowed_repositories       = var.github_allowed_repositories
  github_allowed_branches           = var.github_allowed_branches
  github_allowed_environments       = var.github_allowed_environments
  github_repository_subjects        = var.github_repository_subjects
  owner                             = var.owner
  cost_center                       = var.cost_center
  additional_tags                   = var.additional_tags
}

module "kms" {
  source = "./modules/kms"

  project         = var.project
  environment     = var.environment
  owner           = var.owner
  cost_center     = var.cost_center
  additional_tags = var.additional_tags
}

module "secrets" {
  source = "./modules/secrets"

  project         = var.project
  environment     = var.environment
  owner           = var.owner
  cost_center     = var.cost_center
  additional_tags = var.additional_tags
}

module "logging" {
  source = "./modules/logging"

  project                           = var.project
  environment                       = var.environment
  log_group_retention_days          = var.platform_log_group_retention_days
  platform_log_group_retention_days = var.platform_log_group_retention_overrides
  log_group_kms_key_arn             = module.kms.key_arn
  alarm_actions                     = var.platform_logging_alarm_actions
  owner                             = var.owner
  cost_center                       = var.cost_center
  additional_tags                   = var.additional_tags
}

module "audit" {
  source = "./modules/audit"

  project                       = var.project
  environment                   = var.environment
  logs_bucket_name              = module.storage.logs_bucket_name
  logs_bucket_arn               = module.storage.logs_bucket_arn
  cloudtrail_log_prefix         = var.cloudtrail_log_prefix
  kms_key_arn                   = module.kms.key_arn
  is_multi_region_trail         = var.cloudtrail_is_multi_region_trail
  include_global_service_events = var.cloudtrail_include_global_service_events
  owner                         = var.owner
  cost_center                   = var.cost_center
  additional_tags               = var.additional_tags
}

module "lakehouse" {
  source = "./modules/lakehouse"

  project                          = var.project
  environment                      = var.environment
  curated_bucket_name              = module.storage.curated_bucket_name
  curated_bucket_arn               = module.storage.curated_bucket_arn
  curated_bucket_prefix            = var.lakehouse_curated_bucket_prefix
  create_platform_catalog_database = var.create_platform_catalog_database
  platform_catalog_database_name   = var.platform_catalog_database_name
  product_database_name_pattern    = var.product_database_name_pattern
  product_table_location_pattern   = var.product_table_location_pattern
  owner                            = var.owner
  cost_center                      = var.cost_center
  additional_tags                  = var.additional_tags
}
