aws_region     = "ap-southeast-2"
project        = "data-platform"
environment    = "prod"
account_suffix = "210006516097"

vpc_cidr_block            = "10.2.0.0/16"
public_subnet_cidr_block  = "10.2.1.0/24"
private_subnet_cidr_block = "10.2.2.0/24"

owner       = "Data Platform"
cost_center = "Demo"

github_oidc_provider_arn    = "arn:aws:iam::210006516097:oidc-provider/token.actions.githubusercontent.com"
github_organization         = "Nima-Farhang"
github_allowed_repositories = ["Data-Platform-Demo","Data-Product-Demo","Event-Driven-Lakehouse-Demo"]
github_allowed_environments = ["prod"]
