# Tiny Notes App

Application web de prise de notes, construite autour d'une API REST, d'une interface React et d'une base MySQL.

## Présentation

Tiny Notes App permet de créer, consulter et supprimer des notes via une interface simple. Le projet est structuré en trois couches :

- **Frontend** : interface utilisateur React
- **Backend** : API REST Fastify
- **MySQL** : persistance des données

## Objectifs pédagogiques

Ce projet a été réalisé dans le cadre du module DevOps.

Objectifs :

- Concevoir une API REST avec Node.js et TypeScript
- Utiliser Prisma comme ORM
- Conteneuriser l'application avec Docker
- Orchestrer les services avec Docker Compose
- Mettre en place une base de données MySQL reproductible
- Automatiser les migrations de base de données
- Préparer le projet pour une future intégration CI/CD, Terraform et Ansible

## Fonctionnalités

- Création de notes
- Consultation de toutes les notes
- Consultation d'une note spécifique
- Modification d'une note
- Suppression d'une note
- Interface utilisateur React
- API REST Fastify
- Persistance MySQL
- Migrations Prisma automatiques

## Architecture

```
Frontend :5173 ──HTTP──► Backend :3000 ──Prisma──► MySQL :3306
 (React/Vite)            (Fastify)              (notes_app)
```

| Composant | Rôle | Port (local) |
|-----------|------|--------------|
| Frontend | Interface utilisateur | 5173 |
| Backend | API REST + logique métier | 3000 |
| MySQL | Base de données | 3307 (hôte) → 3306 (conteneur) |

### Docker Compose

```
┌──────────────────────────────┐
│        Docker Network        │
├──────────────────────────────┤
│                              │
│  notes-app-backend           │
│       Port 3000              │
│            │                 │
│            ▼                 │
│      mysql:3306              │
│                              │
│  notes-app-mysql             │
│       Port 3306              │
│                              │
└──────────────────────────────┘
```

## Technologies

| Couche | Stack |
|--------|-------|
| Frontend | React 19, TypeScript, Vite 7 |
| Backend | Node.js, Fastify 5, TypeScript, Prisma 6 |
| Base de données | MySQL 8 |
| Infrastructure | Docker, Docker Compose |

## Structure du projet

```
notes_app_devops/
├── app/
│   ├── backend/
│   │   ├── src/
│   │   │   ├── index.ts          # Point d'entrée Fastify
│   │   │   ├── lib/prisma.ts     # Client Prisma
│   │   │   └── routes/notes.ts   # Routes CRUD Notes
│   │   ├── prisma/
│   │   │   ├── schema.prisma     # Modèle de données
│   │   │   └── migrations/       # Migrations SQL
│   │   ├── Dockerfile
│   │   └── docker-entrypoint.sh  # Migrations au démarrage Docker
│   └── frontend/
│       ├── src/
│       │   ├── App.tsx           # Interface principale
│       │   ├── api/notes.ts      # Client API fetch
│       │   └── style.css
│       └── vite.config.ts
├── docker-compose.yml            # MySQL + Backend
└── README.md
```

## Tests réalisés

**Backend :**

- GET /health
- GET /notes
- POST /notes
- PUT /notes/:id
- DELETE /notes/:id

**Infrastructure :**

- Build Docker backend
- Docker Compose complet
- Recréation complète de la base avec `docker compose down -v`
- Vérification des migrations automatiques Prisma

**Frontend :**

- Création de note
- Suppression de note
- Rafraîchissement automatique de la liste

## Prérequis

- [Docker](https://www.docker.com/) et Docker Compose
- [Node.js](https://nodejs.org/) LTS (v20+) pour le développement local
- npm

## Installation locale

```bash
# Cloner le dépôt
git clone https://github.com/Hadis010/notes-app-devops.git
cd notes_app_devops

# Backend
cd app/backend
cp .env.example .env
npm install
npm run prisma:generate

# Frontend
cd ../frontend
npm install
```

## Démarrage avec Docker Compose

Lance MySQL et le backend. Les migrations Prisma s'exécutent automatiquement au démarrage du conteneur backend.

```bash
# À la racine du projet
docker compose up --build -d
```

Vérification :

```bash
docker compose ps
curl http://localhost:3000/health
```

Frontend (séparément, en dev) :

```bash
cd app/frontend
npm run dev
```

Ouvrir http://localhost:5173

## Démarrage sans Docker

### 1. MySQL

Lancer uniquement MySQL via Docker :

```bash
docker compose up -d mysql
```

Ou utiliser une instance MySQL locale compatible avec la chaîne de connexion définie dans `.env`.

### 2. Backend

```bash
cd app/backend
cp .env.example .env
npm install
npm run prisma:generate
npx prisma migrate dev
npm run dev
```

API disponible sur http://localhost:3000

### 3. Frontend

```bash
cd app/frontend
npm install
npm run dev
```

Interface disponible sur http://localhost:5173

## Commandes Prisma

À exécuter depuis `app/backend/` :

| Commande | Description |
|----------|-------------|
| `npm run prisma:generate` | Génère le client Prisma |
| `npm run prisma:migrate` | Crée et applique une migration (dev) |
| `npx prisma migrate deploy` | Applique les migrations (prod / CI) |
| `npx prisma studio` | Interface graphique pour explorer la BDD |

## Commandes utiles

### Backend (`app/backend/`)

| Commande | Description |
|----------|-------------|
| `npm run dev` | Démarre le serveur en mode développement |
| `npm run build` | Compile TypeScript → `dist/` |
| `npm start` | Lance le serveur compilé |

### Frontend (`app/frontend/`)

| Commande | Description |
|----------|-------------|
| `npm run dev` | Serveur de développement Vite |
| `npm run build` | Build de production |
| `npm run preview` | Prévisualise le build |

### Docker (racine)

| Commande | Description |
|----------|-------------|
| `docker compose up -d --build` | Démarre la stack |
| `docker compose down` | Arrête les conteneurs |
| `docker compose down -v` | Arrête et supprime les volumes (BDD vide) |
| `docker compose logs backend` | Logs du backend |
| `docker compose ps` | État des services |

## Variables d'environnement

### Backend (`app/backend/.env`)

| Variable | Description | Exemple (dev local) |
|----------|-------------|---------------------|
| `DATABASE_URL` | URL de connexion MySQL | `mysql://notes_user:notes_password@localhost:3307/notes_app` |
| `PORT` | Port d'écoute du serveur | `3000` |

**Ports selon le contexte :**

| Contexte | Host MySQL | `DATABASE_URL` |
|----------|------------|----------------|
| Dev local (MySQL via Docker) | `localhost:3307` | Voir `.env.example` |
| Backend dans Docker Compose | `mysql:3306` | Défini dans `docker-compose.yml` |

### MySQL (Docker Compose)

| Variable | Valeur |
|----------|--------|
| `MYSQL_ROOT_PASSWORD` | `root_password` |
| `MYSQL_DATABASE` | `notes_app` |
| `MYSQL_USER` | `notes_user` |
| `MYSQL_PASSWORD` | `notes_password` |

## API REST

Base URL : `http://localhost:3000`

### Health

| Méthode | Route | Description | Réponse |
|---------|-------|-------------|---------|
| `GET` | `/health` | État du serveur | `{ "status": "ok", "hostname": "..." }` |

### Notes

| Méthode | Route | Description | Body |
|---------|-------|-------------|------|
| `GET` | `/notes` | Liste toutes les notes | — |
| `GET` | `/notes/:id` | Récupère une note | — |
| `POST` | `/notes` | Crée une note | `{ "title": "...", "content": "..." }` |
| `PUT` | `/notes/:id` | Met à jour une note | `{ "title": "...", "content": "..." }` |
| `DELETE` | `/notes/:id` | Supprime une note | — |

**Codes de réponse courants :** `200`, `201`, `204`, `400`, `404`, `500`

### Exemple

```bash
curl -X POST http://localhost:3000/notes \
  -H "Content-Type: application/json" \
  -d '{"title":"Ma note","content":"Contenu"}'
```
