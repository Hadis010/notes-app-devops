output "bucket_name" {
  description = "Name of the S3 bucket storing the backups"
  value       = aws_s3_bucket.backups.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket storing the backups"
  value       = aws_s3_bucket.backups.arn
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile granting the database S3 backup access"
  value       = aws_iam_instance_profile.backup.name
}
