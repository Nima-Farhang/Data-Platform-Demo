data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.project}-${var.environment}"

  catalog_id = data.aws_caller_identity.current.account_id

  normalized_project = replace(var.project, "-", "_")

  platform_catalog_database_name = var.platform_catalog_database_name != null ? var.platform_catalog_database_name : "${local.normalized_project}_${var.environment}_platform"

  curated_bucket_location = "s3://${var.curated_bucket_name}/${var.curated_bucket_prefix}/"

  naming_conventions = {
    catalog_id                     = local.catalog_id
    database_name_pattern          = var.product_database_name_pattern
    table_location_pattern         = var.product_table_location_pattern
    curated_bucket_name            = var.curated_bucket_name
    curated_bucket_arn             = var.curated_bucket_arn
    curated_bucket_prefix          = var.curated_bucket_prefix
    curated_bucket_location        = local.curated_bucket_location
    product_database_example       = replace(replace(replace(var.product_database_name_pattern, "<project>", local.normalized_project), "<environment>", var.environment), "<product>", "orders")
    product_table_location_example = replace(replace(replace(replace(replace(var.product_table_location_pattern, "<curated-bucket>", var.curated_bucket_name), "<curated-prefix>", var.curated_bucket_prefix), "<product>", "orders"), "<database>", "${local.normalized_project}_${var.environment}_orders"), "<table>", "events")
  }

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

resource "aws_glue_catalog_database" "platform" {
  count = var.create_platform_catalog_database ? 1 : 0

  catalog_id   = local.catalog_id
  name         = local.platform_catalog_database_name
  description  = "Generic ${var.environment} platform Glue database marker for shared lakehouse catalog conventions."
  location_uri = "${local.curated_bucket_location}platform/"

  parameters = {
    classification           = "platform-catalog-marker"
    curated_bucket_location  = local.curated_bucket_location
    product_database_pattern = var.product_database_name_pattern
    table_location_pattern   = var.product_table_location_pattern
    table_format_convention  = "iceberg"
  }

  tags = merge(
    local.common_tags,
    {
      Name    = local.platform_catalog_database_name
      Purpose = "lakehouse-catalog-foundation"
    }
  )
}
