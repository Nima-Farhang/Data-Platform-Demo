# Lakehouse Module

This module defines the shared Glue Catalog conventions for future Iceberg-based data products.

It intentionally does not create product-specific Glue databases, tables, crawlers, jobs, or Iceberg table definitions. Product repositories should consume this module's outputs and create their own resources using the exported conventions:

- Use `catalog_id` for the AWS Glue Catalog account ID.
- Create product Glue databases with `product_database_name_pattern`.
- Store Iceberg table data below `curated_bucket_location`, following `product_table_location_pattern`.
- Keep product-owned database/table permissions in the product repository deployment role.

When `create_platform_catalog_database` is true, this module creates only a generic platform database marker for the environment. It is not a product database and should not contain product tables.
