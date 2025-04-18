remote_state {
  backend = "s3"

  config = {
    region = local.aws_region
    bucket = "${local.name_prefix}-state"
    key = "${path_relative_to_include()}/terraform.tfstate"
    encrypt = true
  }

  generate = {
    path = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
