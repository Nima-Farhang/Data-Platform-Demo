data "aws_region" "current" {}

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

locals {
  enabled_vpc_endpoint_services = var.enable_vpc_endpoints ? toset(var.vpc_endpoint_services) : toset([])
  gateway_vpc_endpoint_services = contains(local.enabled_vpc_endpoint_services, "s3") ? toset(["s3"]) : toset([])
  interface_vpc_endpoint_services = setsubtract(
    local.enabled_vpc_endpoint_services,
    local.gateway_vpc_endpoint_services
  )
}

resource "aws_security_group" "vpc_endpoints" {
  count = var.enable_vpc_endpoints && length(local.interface_vpc_endpoint_services) > 0 ? 1 : 0

  name        = "${local.name_prefix}-vpc-endpoints-sg"
  description = "Allow HTTPS from the platform VPC to interface VPC endpoints."
  vpc_id      = aws_vpc.platform.id

  ingress {
    description = "HTTPS from VPC CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.platform.cidr_block]
  }

  egress {
    description = "HTTPS responses"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc-endpoints-sg"
    }
  )
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = local.gateway_vpc_endpoint_services

  vpc_id            = aws_vpc.platform.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_vpc.platform.default_route_table_id]

  tags = merge(
    local.common_tags,
    {
      Name    = "${local.name_prefix}-${each.key}-gateway-endpoint"
      Service = each.key
      Type    = "gateway"
    }
  )
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_vpc_endpoint_services

  vpc_id              = aws_vpc.platform.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(
    local.common_tags,
    {
      Name    = "${local.name_prefix}-${each.key}-interface-endpoint"
      Service = each.key
      Type    = "interface"
    }
  )
}
