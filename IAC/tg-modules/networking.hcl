terraform {
  source = "${get_parent_terragrunt_dir()}/../tf-modules/networking"

  # Always include the following file patterns in the Terragrunt copy.
  include_in_copy = [
    ".security_group_rules.json",
    "*.yaml",
  ]
}
