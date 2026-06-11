output "alb_dns_name" {
  description = "Public DNS name of the application load balancer"
  value       = module.loadbalancer.alb_dns_name
}

output "app_public_ips" {
  description = "Public IP addresses of the application instances"
  value       = module.app.public_ips
}

output "app_private_ips" {
  description = "Private IP addresses of the application instances"
  value       = module.app.private_ips
}

output "db_private_ip" {
  description = "Private IP address of the database instance"
  value       = module.database.private_ip
}

output "backup_bucket_name" {
  description = "Name of the S3 bucket storing the backups"
  value       = module.backup.bucket_name
}

output "backup_bucket_arn" {
  description = "ARN of the S3 bucket storing the backups"
  value       = module.backup.bucket_arn
}
