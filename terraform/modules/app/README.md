# Module App

Déploiement des instances applicatives Tiny Notes App.

## Responsabilités

- Provisionnement des instances applicatives
- Déploiement du backend et du frontend
- Configuration runtime via variables d'environnement
- Association aux sous-réseaux applicatifs
- Association aux groupes de sécurité
- Intégration avec le load balancer

## Usage

Ce module dépend du module `network` et utilise les informations de connexion fournies par le module `database`.