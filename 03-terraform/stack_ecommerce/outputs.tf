###############
### Network Outputs
###############
output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_cidrs" {
    value = module.network.private_subnet_cidrs
  
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.network.internet_gateway_id
}

###############
### Security Outputs
###############
output "frontend_sg_id" {
    value = module.security.frontend_sg_id
  
}

output "backend_sg_id" {
    value = module.security.backend_sg_id
  
}

output "database_sg_id" {
    value = module.security.database_sg_id
  
}

###############
### Database Outputs
###############

output "db_endpoint" {
    sensitive = true
    value = module.database.db_endpoint
}

###############
### Storage Outputs
###############


output "bucket_name" {
    description = "Bucket main name"
    value = module.storage.bucket_name
  
}

output "bucket_arn" {
    description = "Bucket main arn"
    value = module.storage.bucket_arn
  
}

###############
### IAM Outputs
###############

output "instance_profile_name" {
    description = "Name of the iam profile instance"
    value = module.iam.instance_profile_name
  
}

###############
### Compute Outputs
###############

output "frontend_public_ips" {
    value = module.compute.frontend_public_ips
    description = "Public IPs of frontend instances"
  
}

output "backend_private_ips" {
    value = module.compute.backend_private_ips
    description = "Private IPs of backend instances"
  
}

output "frontend_instance_ids" {
    value = module.compute.frontend_instance_ids
    description = "Instance IDs of frontend EC2"
}

output "backend_instance_ids" {
    value = module.compute.backend_instance_ids
    description = "Instance IDs of backend EC2"
  
}