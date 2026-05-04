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
