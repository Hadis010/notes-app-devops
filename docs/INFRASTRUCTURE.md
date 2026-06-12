# Infrastructure & Déploiement — Tiny Notes App

Documentation pour reproduire l'environnement **de zéro** : provisioning **Terraform** (AWS) puis configuration/déploiement **Ansible**, avec tests **Molecule**.

---

## 1. Architecture cible

```
Internet
   │  HTTPS :443  (Let's Encrypt via <ip>.sslip.io ; HTTP :80 pour le challenge ACME)
   ▼
[ VM Load Balancer : Caddy ]            ← point d'entrée public unique, TLS terminé ici
   │  round-robin :80
   ├───────────────────────────┐
   ▼                           ▼
[ VM App 1 ]               [ VM App 2 ]   ← ≥ 2 instances : nginx (front) + backend (Docker)
   │  (App 1 = NAT instance / bastion)
   └─────────────┬─────────────┘
                 ▼  :3306 / :22 (ProxyJump)
        [ VM Base de données ]            ← MySQL, sous-réseau privé, sans IP publique
                 │  s3:PutObject (IAM instance profile)
                 ▼
        [ Bucket S3 backups ]             ← dumps SQL gzip, chiffré, versionné
```

- **Load balancer** : **VM dédiée Caddy** (reverse proxy + HTTPS automatique Let's Encrypt via sslip.io). Termine le TLS et répartit en round-robin vers les VMs app.
- **App (≥2)** : EC2 Ubuntu en sous-réseaux **publics**, chaque VM sert le **front (nginx)** ET le **backend** (Docker Compose). L'**App 1** sert aussi de **NAT instance** (sortie Internet des subnets privés, sans NAT Gateway) et de **bastion SSH** vers la DB.
- **Base de données** : EC2 Ubuntu en sous-réseau **privé**, **sans IP publique**, MySQL configuré par Ansible. Jointe uniquement depuis les VMs app.
- **Backups** : bucket S3 (versioning, chiffrement SSE-S3, blocage accès public, lifecycle de rétention). La VM DB y écrit via un **IAM instance profile** au moindre privilège.

## 2. Flux réseau & ports (security groups)

| Source | Destination | Port | Règle (SG) |
|---|---|---|---|
| Internet | Load balancer | 80, 443/tcp | `lb_sg` ingress `ingress_cidr` (HTTP pour l'ACME + HTTPS) |
| Load balancer | VM App | 80/tcp | `app_sg` ingress depuis `lb_sg` (front nginx) |
| Admin (IP /32) | VM App | 22/tcp | `app_sg` ingress depuis `ssh_allowed_cidr` |
| VM App | VM DB | 3306/tcp | `db_sg` ingress depuis `app_sg` |
| VM App | VM DB | 22/tcp | `db_sg` ingress depuis `app_sg` (ProxyJump) |
| Subnets privés | VM App 1 (NAT) | all | `app_sg` ingress depuis `private_subnet_cidrs` (si NAT) |
| VM DB | S3 | 443/tcp | via IAM instance profile (pas d'ingress) |

> Le load balancer **ne connaît pas** la base : aucun flux LB → DB (conforme au conseil du sujet).

## 3. Prérequis

- **Terraform** ≥ 1.5, **AWS CLI** configuré (`aws configure`) avec des droits suffisants.
- Une **paire de clés EC2** existante (`key_name`) et la clé privée correspondante en local.
- **Python 3.11+**, **Ansible**, **Molecule** + driver Docker (voir `ansible/requirements.yml`).
- **Docker** (pour Molecule en local).

## 4. Déploiement Terraform

```sh
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars   # puis éditer
#   ami_id           = "ami-..."   (Ubuntu 22.04 de votre région)
#   key_name         = "votre-cle"
#   ssh_allowed_cidr = "VOTRE_IP/32"            (jamais 0.0.0.0/0)

terraform init
terraform plan
terraform apply
```

Outputs utiles :

```sh
terraform output lb_url            # URL HTTPS de l'app (https://<ip-dashed>.sslip.io)
terraform output lb_public_ip      # IP publique du load balancer
terraform output app_public_ips    # IP publiques des VMs app (SSH)
terraform output app_private_ips   # IP privées des VMs app (backends du LB)
terraform output db_private_ip     # IP privée de la DB
terraform output backup_bucket_name
```

`terraform.tfvars` et `*.tfstate` sont **git-ignorés** (aucun secret commité).

## 5. Inventaire Ansible

Reporter les outputs Terraform dans `ansible/inventories/dev/hosts.yml` (remplacer les placeholders) :

| Placeholder | Source |
|---|---|
| `APP_1_PUBLIC_IP_PLACEHOLDER` / `APP_2_...` | `terraform output app_public_ips` |
| `LB_PUBLIC_IP_PLACEHOLDER` (groupe `loadbalancer`) | `terraform output lb_public_ip` |
| `DB_PRIVATE_IP_PLACEHOLDER` | `terraform output db_private_ip` |
| `BASTION_PUBLIC_IP_PLACEHOLDER` (group_vars/database.yml) | IP publique d'une VM app |
| `lb_domain` + `lb_backends` (group_vars/loadbalancer.yml) | `lb_url` (domaine sslip.io) + `app_private_ips` |
| `BACKUP_BUCKET_NAME_PLACEHOLDER` (group_vars/backup.yml) | `terraform output backup_bucket_name` |

La DB étant privée, elle est jointe via **ProxyJump** par une VM app (déjà configuré dans `group_vars/database.yml`).

## 6. Secrets — Ansible Vault

Les mots de passe ne sont **jamais** en clair dans le dépôt. Ils vivent dans un fichier chiffré.

```sh
cd ansible/inventories/dev/group_vars/all
cp vault.yml.example vault.yml
# éditer vault.yml avec les vraies valeurs (vault_mysql_password, ...)
ansible-vault encrypt vault.yml         # chiffre le fichier
```

Le fichier **chiffré** `vault.yml` peut être commité ; le **mot de passe de vault** est transmis hors dépôt (mail à l'évaluateur). Le fichier `.vault_pass` est git-ignoré.

## 7. Déploiement Ansible

```sh
cd ansible
ansible-galaxy collection install -r requirements.yml

# Tout :
ansible-playbook -i inventories/dev/hosts.yml playbooks/site.yml --ask-vault-pass

# Par concern (tags) :
ansible-playbook -i inventories/dev/hosts.yml playbooks/site.yml --tags database --ask-vault-pass
```

La config multi-environnement passe **par l'inventaire** (`group_vars`), pas par les playbooks. Les rôles :

| Rôle | Responsabilité |
|---|---|
| `common` | paquets de base, timezone |
| `application` | NAT instance (App 1) + Docker + déploiement **front (nginx) + backend** (Compose) |
| `database` | MySQL, bind-address, base `notes_app`, user `notes_user`, droits |
| `backup` | dump MySQL → gzip → S3, planifié par cron |
| `loadbalancer` | **Caddy** : reverse proxy + HTTPS automatique, round-robin vers les VMs app |

## 8. Stratégie de backup

| Paramètre | Valeur | Justification |
|---|---|---|
| **Fréquence** | quotidienne, 02:00 (cron, configurable) | fenêtre de faible activité, une sauvegarde quotidienne est suffisante pour le contexte du projet. |
| **Rétention locale** | 30 jours (`find -mtime +30 -delete`) | purge automatique pour ne pas saturer le disque |
| **Rétention S3** | 30 jours (lifecycle Terraform) + versioning | reprise possible même en cas d'écrasement |
| **Localisation** | `s3://<bucket>/database/<db>-<timestamp>.sql.gz` | chiffré SSE-S3, accès public bloqué |
| **Mécanisme** | `mysqldump --single-transaction \| gzip` puis `aws s3 cp` | dump cohérent sans lock, credentials via IAM instance profile (pas de secret sur la VM) |

**Restauration (manuelle)** — récupérer le dernier dump et le réinjecter sur la VM DB :

```sh
# Sur la VM base de données
LATEST=$(aws s3 ls s3://<bucket>/database/ | sort | tail -1 | awk '{print $4}')
aws s3 cp "s3://<bucket>/database/$LATEST" /tmp/restore.sql.gz
gunzip -c /tmp/restore.sql.gz | mysql notes_app
```

## 9. Tests Molecule

Chaque rôle dispose d'un scénario (`molecule/default/`), driver **Docker**, image **systemd**.

```sh
cd ansible/roles/<role>      # database | common | backup | application | loadbalancer
molecule test                # create → converge → idempotence → verify → destroy
```

| Rôle | Le scénario vérifie |
|---|---|
| `database` | service MySQL actif, base `notes_app`, user `notes_user`, table `Note` |
| `common` | paquets de base installés |
| `backup` | script de backup installé (0700) + job cron planifié |
| `application` | service Docker actif + plugin Docker Compose (déploiement désactivé via `application_deploy_enabled: false`) |
| `loadbalancer` | service Caddy actif + le port 80 répond |

## 10. Décisions d'architecture & limites connues

- **NAT instance plutôt que NAT Gateway** : la VM App 1 fait office de NAT (route `0.0.0.0/0` des subnets privés vers son ENI, `source_dest_check` désactivé, `MASQUERADE`). Permet d'éviter le coût supplémentaire d'une NAT Gateway AWS.
- **DB privée + ProxyJump** : aucun accès direct, SSH/MySQL uniquement depuis le SG app.
- **Load balancer logiciel (Caddy)** : VM dédiée plutôt qu'un ALB natif, pour fournir un **vrai rôle Ansible** de reverse-proxy et **terminer HTTPS** automatiquement (Let's Encrypt via `<ip>.sslip.io`, sans domaine payant). Répartition round-robin vers les VMs app. Le front est servi sur **chaque VM app** (nginx), conformément à 3.2.
- **Secrets** : Vault + `.gitignore` (`terraform.tfvars`, `*.tfstate`, `.vault_pass`) → aucune credential en clair.
