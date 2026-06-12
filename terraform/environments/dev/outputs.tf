output "lb_public_ip" {
  description = "Public IP address of the load balancer"
  value       = module.loadbalancer.public_ip
}

output "lb_url" {
  description = "HTTPS URL of the application (sslip.io domain resolving to the load balancer IP)"
  value       = "https://${replace(module.loadbalancer.public_ip, ".", "-")}.sslip.io"
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
