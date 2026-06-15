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
  owner                     = var.owner
  cost_center               = var.cost_center
  additional_tags           = var.additional_tags
}

module "storage" {
  source = "./modules/storage"

  project         = var.project
  environment     = var.environment
  account_suffix  = var.account_suffix
  kms_key_arn     = module.kms.key_arn
  owner           = var.owner
  cost_center     = var.cost_center
  additional_tags = var.additional_tags
}

module "iam" {
  source = "./modules/iam"

  project                           = var.project
  environment                       = var.environment
  platform_bucket_arns              = module.storage.bucket_arns
  platform_admin_principal_arns     = var.platform_admin_principal_arns
  product_deployment_principal_arns = var.product_deployment_principal_arns
  product_resource_name_prefix      = var.product_resource_name_prefix
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
