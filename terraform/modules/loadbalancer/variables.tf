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

variable "public_subnet_ids" {
  description = "IDs of the public subnets used by the load balancer"
  type        = list(string)
}

variable "app_port" {
  description = "Port on which the application instances serve HTTP traffic"
  type        = number
  default     = 3000
}

variable "ingress_cidr" {
  description = "CIDR block allowed to reach the load balancer on HTTP"
  type        = string
  default     = "0.0.0.0/0"
}

variable "health_check_path" {
  description = "HTTP path used by the target group health check"
  type        = string
  default     = "/health"
}
