# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# CIDR blocks
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

# NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

# EC2
output "instance_bastion_id" {
  description = "ID of the bastion instance"
  value = aws_instance.tf_bastion_instance.id
}

output "instance_bastion_ip" {
    description = "Elastic IP of the bastion instance"
  value = aws_instance.tf_bastion_instance.public_ip
}

output "instance_app_id" {
  description = "ID of the app instance"
  value = aws_instance.tf_app_instance.id
}

output "instance_app_ip" {
      description = "Elastic IP of the app instance"
  value = aws_instance.tf_app_instance.public_ip
}