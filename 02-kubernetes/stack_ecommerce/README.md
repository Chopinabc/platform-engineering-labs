# Application E-commerce Kubernetes — K3s

Application e-commerce 3-tiers déployée sur K3s avec approche prod-first :
isolation réseau stricte (NetworkPolicy), autoscaling (HPA), haute disponibilité (PDB),
cache Redis, sécurité CIS-compliant. 13 ressources Kubernetes.

---

## 🏗️ Architecture

```
           INTERNET
               |
           HTTP :30080
               |
 +----------------------------------+
 |          CLUSTER K3s             |
 |                                  |
 | +------------------------------+ |
 | |         FRONTEND             | |
 | |  Deployment  x2 pods         | |
 | |  HPA : min 2  /  max 6       | |
 | |  PDB : minAvailable 1        | |
 | |  Service NodePort :30080     | |
 | +-------------|----------------+ |
 |  NP: egress backend :3000 + DNS  |
 |               |                  |
 |               v                  |
 | +------------------------------+ |
 | |         BACKEND              | |
 | |  Deployment  x2 pods         | |
 | |  HPA : min 2  /  max 6       | |
 | |  PDB : minAvailable 1        | |
 | |  Service ClusterIP :3000     | |
 | +------|-------------|---------+ |
 |  NP: egress DB :5432 + Redis :6379 + DNS
 |        |             |           |
 |    SQL :5432    Cache :6379      |
 |        v             v           |
 | +-------------+ +--------------+ |
 | | POSTGRESQL  | |    REDIS     | |
 | | StatefulSet | | Deployment   | |
 | | postgres-0  | |   x1 pod     | |
 | | NP: backend | | NP: backend  | |
 | |    only     | |    only      | |
 | +------|------+ +--------------+ |
 |        |                         |
 | +------v------+                  |
 | | PVC 1Gi     |                  |
 | | (RWO)       |                  |
 | +-------------+                  |
 |                                  |
 | Secret : DB creds                |
 | ConfigMap : backend + redis      |
 +----------------------------------+

FLUX BLOQUÉS (NetworkPolicy default-deny) :
  Frontend  ──► PostgreSQL   ❌
  Frontend  ──► Redis        ❌
  Tout pod  ──► DB ou Redis  ❌ (sauf backend)
```

**Stack :**
- **Orchestration** : K3s (distribution Kubernetes lightweight, on-premise)
- **Frontend** : Nginx + HTML/JS — Service NodePort :30080
- **Backend** : Node.js — Service ClusterIP :3000
- **Database** : PostgreSQL — StatefulSet + PVC 1Gi (RWO)
- **Cache** : Redis — Deployment stateless
- **CNI** : Calico (remplace Flannel — active les NetworkPolicies)

---

## 🚀 Quick Start

### Prérequis

- K3s installé avec Calico comme CNI (Flannel désactivé)
- `kubectl` configuré
- Images Docker buildées et accessibles au cluster

---

### 1. Installer K3s avec Calico

```bash
# Installer K3s sans Flannel
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-backend=none --disable-network-policy" sh -

# Installer Calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

# Vérifier que le node est Ready
kubectl get nodes
```

---

### 2. Configurer les secrets

Éditer `k8s/02-secrets/secret.yaml` et remplacer les valeurs avant tout déploiement :

```yaml
stringData:
  POSTGRES_DB: "ecommercedb"       # nom de la base
  POSTGRES_USER: "appuser"         # utilisateur PostgreSQL
  POSTGRES_PASSWORD: "CHANGEME"    # ⚠️ remplacer par un vrai mot de passe
```

```bash
nano k8s/02-secrets/secret.yaml
```

> ⚠️ `secret.yaml` est dans `.gitignore` — ne jamais committer ce fichier avec un vrai mot de passe.
> Le fichier présent dans le repo contient uniquement des valeurs exemples.

---

### 3. Déployer l'application

> Les dossiers sont numérotés : **respecter l'ordre de déploiement**.

```bash
kubectl apply -f k8s/00-namespace/
kubectl apply -f k8s/01-configmaps/
kubectl apply -f k8s/02-secrets/
kubectl apply -f k8s/03-storage/
kubectl apply -f k8s/04-postgres/
kubectl apply -f k8s/05-redis/
kubectl apply -f k8s/06-backend/
kubectl apply -f k8s/07-frontend/
```

---

### 4. Vérifier le déploiement

```bash
# Vérifier tous les pods
kubectl get pods -n ecommerce

# Vérifier les services
kubectl get svc -n ecommerce

# Accéder à l'application (remplacer NODE_IP par l'IP de ton node K3s)
http://NODE_IP:30080
```

---

### Supprimer

```bash
kubectl delete namespace ecommerce
```

---

## 🔐 Sécurité

### Mesures appliquées

✅ **NetworkPolicy isolation stricte** : 4 policies, default-deny implicite
✅ **CIS-compliant** : `runAsNonRoot: true` + `drop: ["ALL"]` sur tous les pods
✅ **Secrets Kubernetes** : credentials DB en Secret (pas en clair dans les manifests)
✅ **Resource limits** : requests + limits CPU/Memory sur tous les pods
✅ **Health checks** : readiness + liveness probes sur backend et frontend
✅ **PDB** : `minAvailable: 1` sur backend et frontend (0 downtime lors des rolling updates)
✅ **HPA** : autoscaling CPU — frontend et backend scalent indépendamment

### Flux réseau autorisés

| Source | Destination | Port | Autorisé |
|---|---|---|---|
| Internet | Frontend (NodePort) | 30080 | ✅ |
| Frontend | Backend | 3000 | ✅ |
| Backend | PostgreSQL | 5432 | ✅ |
| Backend | Redis | 6379 | ✅ |
| Frontend | PostgreSQL | - | ❌ BLOQUÉ |
| Frontend | Redis | - | ❌ BLOQUÉ |

---


## 📁 Structure

```
stack_ecommerce/
│
├── app/
│   ├── backend/
│   │   ├── Dockerfile         ← Image Node.js
│   │   ├── server.js          ← API Express (/health, /visit, /init-db)
│   │   └── package.json
│   └── frontend/
│       ├── Dockerfile         ← Image Nginx Alpine
│       ├── nginx.conf         ← Reverse proxy /api/* → backend:3000
│       ├── index.html
│       └── app.js
│
└── k8s/                       ← Manifests (déployer dans l'ordre numéroté)
    ├── 00-namespace/
    │   └── namespace.yaml
    ├── 01-configmaps/
    │   ├── backend-config.yaml
    │   └── redis-configmaps.yaml
    ├── 02-secrets/
    │   └── secret.yaml        ← ⚠️ gitignored — valeurs exemples uniquement
    ├── 03-storage/
    │   └── postgres-pvc.yaml
    ├── 04-postgres/
    │   ├── postgres-statefulset.yaml
    │   ├── postgres-service.yaml
    │   └── postgres-netpol.yaml
    ├── 05-redis/
    │   ├── redis-deployment.yaml
    │   ├── redis-service.yaml
    │   └── redis-netpol.yaml
    ├── 06-backend/
    │   ├── backend-deployment.yaml
    │   ├── backend-service.yaml
    │   ├── backend-hpa.yaml
    │   ├── backend-pdb.yaml
    │   └── backend-netpol.yaml
    └── 07-frontend/
        ├── frontend-deployment.yaml
        ├── frontend-service.yaml
        ├── frontend-hpa.yaml
        ├── frontend-pdb.yaml
        └── frontend-netpol.yaml
```

---

## 🐛 Troubleshooting

**Pods en `Pending` après déploiement**
```bash
kubectl describe pod <pod-name> -n ecommerce
# Vérifier les events en bas — souvent un problème de PVC ou de resource limits
```

**NetworkPolicy bloque un flux attendu**
```bash
# Vérifier que Calico est installé (Flannel ne supporte pas les NetworkPolicies)
kubectl get pods -n kube-system | grep calico

# Tester la connectivité depuis un pod
kubectl exec -it <pod-name> -n ecommerce -- curl http://backend-service:3000/health
```

**HPA bloqué — pas de scaling**
```bash
# Vérifier que metrics-server est installé
kubectl top pods -n ecommerce

# Si erreur → installer metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

**PostgreSQL ne démarre pas**
```bash
# Vérifier le PVC
kubectl get pvc -n ecommerce

# Vérifier les logs
kubectl logs postgres-0 -n ecommerce
```

---

## 🔭 Axes d'évolution

- [ ] Ingress Controller (Traefik/Nginx) + TLS — remplacer NodePort
- [ ] Helm Chart — templating des manifests par environnement
- [ ] Monitoring — Prometheus + Grafana (métriques pods + HPA)
- [ ] Pipeline CI/CD — build image + `kubectl apply` sur push (GitHub Actions)
- [ ] PostgreSQL HA — réplication avec CloudNativePG

---

## 👤 Auteur

**Vincent JOAQUIM**