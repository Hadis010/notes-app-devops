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
