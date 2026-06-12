output "security_group_id" {
  description = "ID of the load balancer security group"
  value       = aws_security_group.lb.id
}

output "instance_id" {
  description = "ID of the load balancer instance"
  value       = aws_instance.lb.id
}

output "public_ip" {
  description = "Public IP address of the load balancer"
  value       = aws_instance.lb.public_ip
}

output "public_dns" {
  description = "Public DNS name of the load balancer instance"
  value       = aws_instance.lb.public_dns
}
