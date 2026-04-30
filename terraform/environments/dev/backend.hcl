bucket         = "data-platform-dev-terraform-state-replace-with-unique-suffix"
key            = "environments/dev/terraform.tfstate"
region         = "ap-southeast-2"
dynamodb_table = "data-platform-dev-terraform-locks"
encrypt        = true
