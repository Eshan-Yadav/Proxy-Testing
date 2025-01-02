

locals {
  aws_region_vars    = read_terragrunt_config(find_in_parent_folder("region.hcl"))
  aws_namespace_vars = find_in_parent_folder("namespace.hcl")



  aws_region    = local.aws_region_vars.region
  aws_namespace = local.aws_namespace_vars.environment
}


input {

}


include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "networking" {
  path = find_in_parent_folders("networking.hcl")

}


