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

# Modules d'infrastructure :
# - network : VPC, sous-réseaux, routage et sécurité réseau
# - database : base MySQL/RDS non exposée publiquement
# - app : instances applicatives backend + frontend
# - loadbalancer : point d'entrée HTTP/HTTPS
# - backup : stockage et stratégie de sauvegarde