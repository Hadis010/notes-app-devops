output "bucket_name" {
  description = "Name of the S3 bucket storing the backups"
  value       = aws_s3_bucket.backups.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket storing the backups"
  value       = aws_s3_bucket.backups.arn
}
