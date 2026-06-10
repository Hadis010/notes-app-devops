# Module Load Balancer

Gestion du point d'entrée unique de l'application.

## Responsabilités

- Création du load balancer
- Répartition du trafic vers les instances applicatives
- Configuration des health checks
- Terminaison HTTP/HTTPS
- Exposition publique contrôlée de l'application

## Usage

Ce module utilise les instances du module `app` et les groupes de sécurité du module `network`.