aws_region     = "ap-southeast-2"
project        = "data-platform"
environment    = "dev"
account_suffix = "210006516097"

vpc_cidr_block            = "10.0.0.0/16"
public_subnet_cidr_block  = "10.0.1.0/24"
private_subnet_cidr_block = "10.0.2.0/24"

owner       = "Data Platform"
cost_center = "Demo"

create_github_oidc_provider = true
github_organization         = "Nima-Farhang"
github_allowed_repositories = ["Data-Platform-Demo"]
github_allowed_environments = ["dev"]
