

locals {
  aws_region_vars    = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  aws_namespace_vars = read_terragrunt_config(find_in_parent_folders("namespace.hcl")).locals



  aws_region    = local.aws_region_vars.region
  aws_namespace = local.aws_namespace_vars.environment
}

inputs = {
  namespace = local.aws_namespace
}


include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "networking" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/../tg-modules/networking.hcl"
}


