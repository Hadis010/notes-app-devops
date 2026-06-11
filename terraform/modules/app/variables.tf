variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the application instances are created"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets used to place the application instances"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID used for the application instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the application instances"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the EC2 key pair used for SSH access"
  type        = string
}

variable "instance_count" {
  description = "Number of identical application instances to create"
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count >= 2
    error_message = "instance_count must be at least 2 to place the application behind the load balancer."
  }
}

variable "app_port" {
  description = "Port on which the application serves HTTP traffic"
  type        = number
  default     = 3000
}

variable "lb_security_group_id" {
  description = "Security group ID of the load balancer allowed to reach the application"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the load balancer target group the instances register to"
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

variable "root_volume_size" {
  description = "Size in GB of the application root EBS volume"
  type        = number
  default     = 10
}
