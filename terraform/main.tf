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
  github_oidc_provider_arn          = var.github_oidc_provider_arn
  github_repository_subjects        = var.github_repository_subjects
  owner                             = var.owner
  cost_center                       = var.cost_center
  additional_tags                   = var.additional_tags
}

module "secrets" {
  source = "./modules/secrets"

  project         = var.project
  environment     = var.environment
  owner           = var.owner
  cost_center     = var.cost_center
  additional_tags = var.additional_tags
}
