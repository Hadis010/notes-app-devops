# Ansible — Tiny Notes App

Configuration des serveurs provisionnés par Terraform.

## Structure

- `inventories/<env>/hosts.yml` — hôtes regroupés par rôle : `app`, `database`, `loadbalancer`, `backup`.
- `inventories/<env>/group_vars/` — variables par groupe. La configuration multi-environnement passe par l'inventaire, pas par les playbooks.
- `playbooks/site.yml` — playbook principal : applique chaque rôle au bon groupe.
- `roles/` — un rôle par responsabilité :
  - `common` — base appliquée à tous les hôtes.
  - `application` — déploiement backend/frontend.
  - `database` — MySQL auto-géré.
  - `loadbalancer` — configuration liée au point d'entrée applicatif.
  - `backup` — sauvegardes vers S3.

## Utilisation

```sh
ansible-playbook -i inventories/dev/hosts.yml playbooks/site.yml
```

## Conventions

- Aucune IP, clé SSH ou secret réel dans le dépôt : remplacer les placeholders et stocker les secrets avec `ansible-vault`.
- La base est privée : elle est jointe via une instance `app` servant de bastion (ProxyJump), voir `group_vars/database.yml`.
- L'inventaire `prod` doit refléter la structure de `dev`.
