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

```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \aquasec/trivy image miniapp_3Tiers-backend:latest
```

**Résultats :**
- **npm audit** : ✅ 0 vulnérabilités
- **Alpine** : 2 CRITICAL, 2 HIGH, 23 MEDIUM, 5 LOW
- **Node.js deps** : 0 CRITICAL, 4 HIGH, 0 MEDIUM, 2 LOW

---

### Analyse des vulnérabilités

#### 🔴 CRITICAL - OpenSSL (Alpine 3.21.3)

| CVE | Composant | Impact | Fix |
|-----|-----------|--------|-----|
| CVE-2025-15467 | libcrypto3 / libssl3 | RCE via QUIC protocol | OpenSSL 3.3.6 |
| CVE-2025-69419 | libcrypto3 / libssl3 | Code execution via PKCS#12 | OpenSSL 3.3.6 |

**Évaluation du risque :** 🟡 **Faible**
- Protocole QUIC non utilisé par l'application
- PKCS#12 non utilisé en runtime
- Alpine 3.21.3 n'a pas encore intégré le patch OpenSSL 3.3.6

#### 🟠 HIGH - Dépendances Node.js transitives

| Package | CVE | Contexte |
|---------|-----|----------|
| cross-spawn | CVE-2024-21538 | Build-time uniquement |
| glob | CVE-2025-64756 | Build-time uniquement |
| tar | CVE-2026-23745, CVE-2026-23950 | npm install uniquement |

**Évaluation du risque :** 🟡 **Faible**
- Ces packages sont des dépendances transitives de build
- Non présents dans le runtime de l'application Express
- npm audit ne les remonte pas (non exploitables)

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