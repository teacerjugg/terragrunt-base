locals {
  terraform_version      = "1.11.4"
  aws_provider_version   = "5.94.1"
  awscc_provider_version = "1.36.0"
  aws_region             = "ap-northeast-1"

  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

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
    region = local.aws_region
    bucket = "${local.name_prefix}-state"
    key = "${path_relative_to_include()}/terraform.tfstate"
    encrypt = true
  }

  generate = {
    path = "_backend.tf"
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

# inputs = merge(
#   {
#     project = local.project
#     name_prefix = local.name_prefix
#   },
#   local.environment_vars.locals,
#   )
