locals {
  base_source_url = "tfr://registry.terraform.io/terraform-aws-modules/vpc/aws"

  vpc_cidr = "10.0.0.0/16"
}

inputs = {
  cidr = local.vpc_cidr

  public_subnets   = [for i in range(0, 3) : cidrsubnet(local.vpc_cidr, 4, i)]
  private_subnets  = [for i in range(3, 6) : cidrsubnet(local.vpc_cidr, 4, i)]
  database_subnets = [for i in range(6, 9) : cidrsubnet(local.vpc_cidr, 4, i)]

  enable_dns_hostnames = true
  enable_dns_support   = true
}
