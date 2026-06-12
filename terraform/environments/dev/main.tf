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

  project_name             = var.project_name
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_subnet_cidrs     = var.private_subnet_cidrs
  availability_zones       = var.availability_zones
  nat_network_interface_id = module.app.nat_network_interface_id
}

# Load balancer  
module "loadbalancer" {
  source = "../../modules/loadbalancer"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.network.vpc_id
  subnet_id        = module.network.public_subnet_ids[0]
  ami_id           = var.ami_id
  instance_type    = var.lb_instance_type
  key_name         = var.key_name
  ssh_allowed_cidr = var.ssh_allowed_cidr
}

# Application 
module "app" {
  source = "../../modules/app"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.network.vpc_id
  public_subnet_ids    = module.network.public_subnet_ids
  private_subnet_cidrs = var.private_subnet_cidrs
  ami_id               = var.ami_id
  instance_type        = var.app_instance_type
  key_name             = var.key_name
  lb_security_group_id = module.loadbalancer.security_group_id
  ssh_allowed_cidr     = var.ssh_allowed_cidr
  enable_nat_instance  = true
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
  iam_instance_profile  = module.backup.instance_profile_name
}

# Backup : bucket S3 chiffré et versionné pour les sauvegardes de la base.
module "backup" {
  source = "../../modules/backup"

  project_name   = var.project_name
  environment    = var.environment
  retention_days = var.backup_retention_days
}