locals {
  aws_region = "ap-northeast-1"

  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  secret_vars      = try(yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yml"))), {})

  project     = "terragrunt-test"
  environment = local.environment_vars.locals.environment
  name_prefix = "${local.project}-${local.environment}"

  tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
  cc_tags = [
    for k, v in local.tags : {
      key   = k
      value = v
    }
  ]
}

remote_state {
  backend = "s3"

  config = {
    region       = local.aws_region
    bucket       = "${local.name_prefix}-state"
    key          = "${path_relative_to_include()}/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
  }

  generate = {
    path      = "_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "providers" {
  path      = "_providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOT
    provider "aws" {
      region = "${local.aws_region}"
      default_tags {
        tags = {
          Project = "${local.project}"
          Environment = "${local.environment}"
          ManagedBy = "Terraform"
        }
      }
    }

    provider "aws" {
      alias  = "virginia"
      region = "us-east-1"

      default_tags {
        tags = {
          Project = "${local.project}"
          Environment = "${local.environment}"
          ManagedBy = "Terraform"
        }
      }
    }

    provider "awscc" {
      region = "${local.aws_region}"
    }
  EOT
}
