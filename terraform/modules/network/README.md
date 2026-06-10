# Module Network

Gestion du réseau AWS pour Tiny Notes App.

## Responsabilités

- Création du VPC
- Création des sous-réseaux publics et privés
- Configuration de l'Internet Gateway
- Configuration des tables de routage
- Définition des groupes de sécurité
- Contrôle des flux réseau entre load balancer, application et base de données

## Usage

Ce module est appelé depuis `terraform/environments/dev/main.tf`.