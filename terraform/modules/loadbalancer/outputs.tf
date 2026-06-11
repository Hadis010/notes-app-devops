output "alb_dns_name" {
  description = "Public DNS name of the application load balancer"
  value       = aws_lb.this.dns_name
}

output "alb_arn" {
  description = "ARN of the application load balancer"
  value       = aws_lb.this.arn
}

output "target_group_arn" {
  description = "ARN of the target group the application instances register to"
  value       = aws_lb_target_group.this.arn
}

output "security_group_id" {
  description = "ID of the load balancer security group"
  value       = aws_security_group.lb.id
}
