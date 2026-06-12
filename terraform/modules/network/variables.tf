variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "public_subnet_cidrs must contain exactly 2 CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "private_subnet_cidrs must contain exactly 2 CIDR blocks."
  }
}

variable "availability_zones" {
  description = "Availability zones used for subnet placement"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "availability_zones must contain exactly 2 availability zones."
  }
}

variable "nat_network_interface_id" {
  description = "Primary network interface ID of the NAT instance used as the default route for the private subnets. Only used when enable_nat_route is true."
  type        = string
  default     = null
}

variable "enable_nat_route" {
  description = "When true, create a private route table sending the private subnets' egress through the NAT instance ENI. Kept as a static flag so the resource count is known at plan time."
  type        = bool
  default     = false
}
