variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the load balancer is created"
  type        = string
}

variable "subnet_id" {
  description = "ID of the public subnet hosting the load balancer VM"
  type        = string
}

variable "ami_id" {
  description = "AMI ID used for the load balancer instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the load balancer"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the EC2 key pair used for SSH access"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Administration IP allowed to open SSH sessions to the load balancer, in CIDR notation (example: X.X.X.X/32). Required, must not be open to everyone."
  type        = string

  validation {
    condition     = var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "ssh_allowed_cidr must not be 0.0.0.0/0; set a restrictive admin CIDR such as X.X.X.X/32."
  }
}

variable "ingress_cidr" {
  description = "CIDR block allowed to reach the load balancer on HTTP/HTTPS"
  type        = string
  default     = "0.0.0.0/0"
}

variable "root_volume_size" {
  description = "Size in GB of the load balancer root EBS volume"
  type        = number
  default     = 10
}
