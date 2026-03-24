output "frontend_public_ips" {
    value = aws_instance.frontend[*].public_ip
    description = "Public IPs of frontend instances"
  
}

output "backend_private_ips" {
    value = aws_instance.backend[*].private_ip
    description = "Private IPs of backend instances"
  
}

output "frontend_instance_ids" {
    value = aws_instance.frontend[*].id
    description = "Instance IDs of frontend EC2"
}

output "backend_instance_ids" {
    value = aws_instance.backend[*].id
    description = "Instance IDs of backend EC2"
  
}