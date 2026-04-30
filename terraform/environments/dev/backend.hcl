bucket         = "data-platform-terraform-state-replace-with-unique-suffix"
key            = "environments/dev/terraform.tfstate"
region         = "ap-southeast-2"
dynamodb_table = "data-platform-terraform-locks"
encrypt        = true
