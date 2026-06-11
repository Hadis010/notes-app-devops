variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the database instance is created"
  type        = string
}

variable "subnet_id" {
  description = "ID of the private subnet hosting the database instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID used for the database instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the database"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the EC2 key pair used for SSH access"
  type        = string
}

variable "app_security_group_id" {
  description = "Security group ID of the application instances allowed to reach the database"
  type        = string
}

variable "db_port" {
  description = "TCP port exposed by the MySQL server"
  type        = number
  default     = 3306
}

variable "root_volume_size" {
  description = "Size in GB of the database root EBS volume"
  type        = number
  default     = 20
}

variable "iam_instance_profile" {
  description = "Optional IAM instance profile name attached to the database instance (e.g. for S3 backups)"
  type        = string
  default     = null
}
