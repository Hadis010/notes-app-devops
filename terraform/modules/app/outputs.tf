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

output "nat_instance_id" {
  description = "ID of the first application instance, also used as bastion and NAT instance"
  value       = aws_instance.app[0].id
}

output "nat_network_interface_id" {
  description = "Primary network interface ID of the NAT instance, used as the default route target for the private subnets"
  value       = aws_instance.app[0].primary_network_interface_id
}
