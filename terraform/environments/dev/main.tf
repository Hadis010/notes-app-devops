terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Réseau 
module "network" {
  source = "../../modules/network"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# Load balancer  
module "loadbalancer" {
  source = "../../modules/loadbalancer"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  app_port          = var.app_port
}

# Application 
module "app" {
  source = "../../modules/app"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.network.vpc_id
  public_subnet_ids    = module.network.public_subnet_ids
  ami_id               = var.ami_id
  instance_type        = var.app_instance_type
  key_name             = var.key_name
  app_port             = var.app_port
  lb_security_group_id = module.loadbalancer.security_group_id
  target_group_arn     = module.loadbalancer.target_group_arn
  ssh_allowed_cidr     = var.ssh_allowed_cidr
}

# Base de données 
module "database" {
  source = "../../modules/database"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  subnet_id             = module.network.private_subnet_ids[0]
  ami_id                = var.ami_id
  instance_type         = var.db_instance_type
  key_name              = var.key_name
  app_security_group_id = module.app.security_group_id
}