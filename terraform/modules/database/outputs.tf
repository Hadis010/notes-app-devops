output "instance_id" {
  description = "ID of the database EC2 instance"
  value       = aws_instance.db.id
}

output "private_ip" {
  description = "Private IP address of the database instance"
  value       = aws_instance.db.private_ip
}

output "security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db.id
}
