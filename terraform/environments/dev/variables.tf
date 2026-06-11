variable "aws_region" {
  description = "AWS region for the dev environment"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Administration IP allowed to open SSH sessions to the application instances, in CIDR notation (example: X.X.X.X/32). Required, must not be open to everyone."
  type        = string

  validation {
    condition     = var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "ssh_allowed_cidr must not be 0.0.0.0/0; set a restrictive admin CIDR such as X.X.X.X/32."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "Availability zones used for subnet placement"
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b"]
}

variable "ami_id" {
  description = "AMI ID used for the application and database instances"
  type        = string
}

variable "key_name" {
  description = "Name of the existing EC2 key pair used for SSH access"
  type        = string
}

variable "app_instance_type" {
  description = "EC2 instance type for the application instances"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_type" {
  description = "EC2 instance type for the database instance"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Port on which the application serves HTTP traffic"
  type        = number
  default     = 3000
}
