locals {
  terraform_version      = "1.11.4"
  aws_provider_version   = "5.94.1"
  awscc_provider_version = "1.36.0"
  aws_region             = "ap-northeast-1"

  path_parts = reverse(split("/", path_relative_to_include()))

  project     = "terragrunt-test"
  environment = local.path_parts[1]
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

inputs = {
  name_prefix = local.name_prefix
}

remote_state {
  backend = "s3"

  config = {
    region  = local.aws_region
    bucket  = "${local.name_prefix}-state"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    encrypt = true
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOT
    terraform {
      required_version = "${local.terraform_version}"

      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "${local.aws_provider_version}"
        }
        awscc = {
          source  = "hashicorp/awscc"
          version = "${local.awscc_provider_version}"
        }
      }
    }
  EOT
}

generate "providers" {
  path      = "providers.tf"
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
