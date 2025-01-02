terraform {
  source = "../tf-moudules/ec2-linux"

  # Always include the following file patterns in the Terragrunt copy.
  include_in_copy = [
    ".security_group_rules.json",
    "*.yaml",
  ]
}

locals {
  namespace_vars = find_in_parent_folder(read_terragrunt_config("namespace.hcl"))
  namespace      = namespace_vars.environment
}

inputs {
  namespace = local.namespace
}
