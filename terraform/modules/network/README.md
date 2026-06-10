# Module Network

Gestion du réseau AWS pour Tiny Notes App.

## Responsabilités

- Création du VPC
- Création des sous-réseaux publics et privés
- Configuration de l'Internet Gateway
- Configuration des tables de routage
- Base réseau uniquement pour les autres modules Terraform
- Pas de NAT Gateway pour limiter les coûts
- Pas de security groups créés à ce stade

## Usage

Ce module est appelé depuis `terraform/environments/dev/main.tf`.