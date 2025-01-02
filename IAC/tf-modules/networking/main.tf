module "vpc" {
  source = "cloudposse/vpc/aws"
  version     = "2.1.1"
  namespace = var.namespace
  name      = "app-${var.namespace}"
  ipv4_primary_cidr_block = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = false
}

module "public_subnet" {
  source = "cloudposse/dynamic-subnets/aws"
  version     = "2.4.2"
  namespace          = var.namespace
  name               = "app-${var.namespace}-public"
  availability_zones = ["us-east-1a"]
  vpc_id             = module.vpc.vpc_id
  igw_id             = [module.vpc.igw_id]
  ipv4_cidr_block          = "10.0.0.0/17"
}

module "private_subnet" {
  source = "cloudposse/dynamic-subnets/aws"
  version     = "2.4.2"
  namespace          = var.namespace
  name               = "app-${var.namespace}-private"
  availability_zones = ["us-east-1b"]
  vpc_id             = module.vpc.vpc_id
  ipv4_cidr_block          = "10.0.128.0/17"

  nat_gateway_enabled    = false
  public_subnets_enabled = false
}