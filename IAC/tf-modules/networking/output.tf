output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The primary CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "igw_id" {
  description = "The Internet Gateway ID associated with the VPC"
  value       = module.vpc.igw_id
}

#Public subnet
output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = module.public_subnet.public_subnet_ids
}

output "public_subnet_cidr" {
  description = "The CIDR block of the public subnet"
  value       = module.public_subnet.public_subnet_cidrs
}

#Private Subnet
output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = module.private_subnet.private_subnet_ids
}

output "private_subnet_cidr" {
  description = "The CIDR block of the private subnet"
  value       = module.private_subnet.private_subnet_cidrs
}
