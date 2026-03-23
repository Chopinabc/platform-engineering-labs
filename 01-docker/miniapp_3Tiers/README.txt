# Application 3-tiers Dockerisée

Application complète containerisée avec frontend Nginx, backend Node.js et 
base PostgreSQL, optimisée pour la production avec approche DevSecOps.

---

## 🏗️ Architecture

```
Internet → Nginx (80) → Express (3000) → PostgreSQL (5432)
           ├─ Static files (HTML/JS)
           └─ Reverse proxy /api/* → backend
```

**Stack :**
- **Frontend** : Nginx Alpine (reverse proxy + static)
- **Backend** : Node.js 18 Alpine + Express (API REST)
- **Database** : PostgreSQL 17 (volume persistant)
- **Orchestration** : Docker Compose
- **DevSecOps** : Multi-stage builds, user non-root, health checks

---

## 🚀 Quick Start

```bash

# Configurer les variables d'environnement
cp .env.example .env
# Éditer .env et définir DB_PASSWORD et DB_USER

# Lancer la stack
docker-compose up -d

# Vérifier le statut
docker-compose ps

# Accéder à l'application
http://localhost:8080
```

**Arrêter :**
```bash
docker-compose down
```

**Reset complet (DB incluse) :**
```bash
docker-compose down -v
```

---

## 🔐 Sécurité

### Scan Trivy

---

### Mesures de sécurité appliquées

✅ **Multi-stage builds** : Image 80 MB (vs 300+ MB standard)  
✅ **User non-root** : UID/GID 1001 (pas de privilèges)  
✅ **Health checks** : Détection automatique des défaillances  
✅ **Secrets externalisés** : Variables d'environnement (.env)  
✅ **Prod dependencies only** : npm ci --only=production  
✅ **Scan systématique** : Trivy dans le workflow  

---

## 📁 Structure

```
.
├── backend/
│   ├── Dockerfile         # Multi-stage build optimisé
│   ├── server.js          # API Express (routes /health, /visit, /init-db)
│   └── package.json
├── frontend/
│   ├── Dockerfile
│   ├── nginx.conf         # Reverse proxy /api/* → backend:3000
│   └── public/
│       ├── index.html
│       ├── app.js
│       ├── 404.html       # Page d'erreur custom
│       └── 50x.html       # Page backend unavailable
├── docker-compose.yaml    # Orchestration avec health checks
└── .env                   # Variables d'environnement
```

---

## 🐛 Troubleshooting

**Erreur 503 (Backend unavailable)**
```bash
# Vérifier le statut des services
docker-compose ps
# Attendre que backend soit "healthy" (10-15s)
```

**Port 8080 **
```bash
frontend:
  ports:
    - "8080:80"  # Utiliser le port 8080
```

**Voir les logs**
```bash
docker-compose logs -f backend
```

---

## 👤 Auteur

**Vincent JOAQUIM**  
