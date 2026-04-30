locals {
  name_prefix = "${var.project}-${var.environment}"

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

resource "aws_vpc" "platform" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

resource "aws_internet_gateway" "platform" {
  vpc_id = aws_vpc.platform.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-internet-gateway"
    }
  )
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.platform.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-subnet"
      Tier = "public"
    }
  )
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.platform.id
  cidr_block        = var.private_subnet_cidr_block
  availability_zone = var.availability_zone

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-subnet"
      Tier = "private"
    }
  )
}
