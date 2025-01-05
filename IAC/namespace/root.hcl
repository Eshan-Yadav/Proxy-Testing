locals {
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  region_vars    = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  namespace_vars = read_terragrunt_config(find_in_parent_folders("namespace.hcl")).locals

  account_name = local.account_vars.account_name
  aws_region   = local.region_vars.region
  namespace    = local.namespace_vars.environment

  //key
  access_key_var = read_terragrunt_config(find_in_parent_folders("key.hcl")).locals
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
  provider "aws"{
    region="${local.aws_region}"
  }
  EOF
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${local.namespace}-tf-state-${local.account_name}-${local.aws_region}"
    key            = "${path_relative_to_include()}/tf.tfstate"
    region         = local.aws_region
    dynamodb_table = "tf-locks"
  }
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}