output "instance_ids" {
  description = "IDs of the application instances"
  value       = aws_instance.app[*].id
}

output "public_ips" {
  description = "Public IP addresses of the application instances"
  value       = aws_instance.app[*].public_ip
}

output "private_ips" {
  description = "Private IP addresses of the application instances"
  value       = aws_instance.app[*].private_ip
}

output "security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app.id
}
