locals {
  vpc_cidr = "10.0.0.0/16"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

include "shared" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/shared/vpc.hcl"
  expose = true
}

dependency "data" {
  config_path = "../data"

  mock_outputs = {
    aws_availability_zone_names = ["ap-northeast-1x", "ap-northeast-1y", "ap-northeast-1z"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate"]
}

terraform {
  source = "${include.shared.locals.base_source_url}?version=5.19.0"
}

inputs = {
  name = "${include.root.locals.name_prefix}-vpc"
  cidr = local.vpc_cidr
  azs = slice(dependency.data.outputs.aws_availability_zone_names, 0, 3)

  public_subnets   = [for i in range(0, 3) : cidrsubnet(local.vpc_cidr, 4, i)]
  private_subnets  = [for i in range(3, 6) : cidrsubnet(local.vpc_cidr, 4, i)]
  database_subnets = [for i in range(6, 9) : cidrsubnet(local.vpc_cidr, 4, i)]
}
