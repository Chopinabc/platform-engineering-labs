# Infrastructure E-commerce AWS — Terraform

Infrastructure AWS 3-tiers provisionnée en IaC pour une application e-commerce.
Approche security-first : accès SSM uniquement, chiffrement KMS, remote state S3 verrouillé.

---

## 🏗️ Architecture

```
INTERNET ──► Internet Gateway
                    │
┌───────────────────────────────────────────────┐
│  VPC  10.0.0.0/16                             │
│                                               │
│  ┌─────────────────────────────────────────┐  │
│  │  PUBLIC SUBNET                          │  │
│  │  us-east-1a (10.0.1.0/24)               │  │
│  │  us-east-1b (10.0.2.0/24)               │  │
│  │                                         │  │
│  │  EC2 FRONTEND x2                        │  │
│  │  SG : :80/:443 ← Internet               │  │
│  │  IMDSv2 │ SSM only │ EBS gp3 chiffré    │  │
│  └─────────────────────────────────────────┘  │
│         ↓ SG Backend : :3000 ← SG Frontend    │
│  ┌─────────────────────────────────────────┐  │
│  │  PRIVATE SUBNET                         │  │
│  │  us-east-1a (10.0.3.0/24)               │  │
│  │  us-east-1b (10.0.4.0/24)               │  │
│  │                                         │  │
│  │  EC2 BACKEND x2                         │  │
│  │  SG : :3000 ← SG Frontend               │  │
│  │  IMDSv2 │ SSM only │ EBS gp3 chiffré    │  │
│  │         ↓ SG RDS : :5432 ← SG Backend   │  │
│  │  RDS PostgreSQL 17.6                    │  │
│  │  KMS chiffré │ Backup 7j │ No public IP │  │
│  └─────────────────────────────────────────┘  │
│                                               │
│  VPC Endpoints SSM (trafic sans Internet)     │
└───────────────────────────────────────────────┘

S3          → Remote state (AES-256 + versioning + lifecycle 90j)
DynamoDB    → State lock (anti-corruption concurrente)
```

**Stack :**
- **IaC** : Terraform >= 1.5 — provider AWS ~> 6.0
- **Compute** : EC2 t3.micro × 4 — Amazon Linux 2
- **Database** : RDS PostgreSQL 17.6 (subnet privé, KMS, backup 7j)
- **Réseau** : VPC, 4 subnets, IGW, Route Tables, 4 Security Groups
- **Accès** : IAM Role SSM — 0 port 22 exposé
- **State** : S3 (AES-256 + versioning) + DynamoDB (lock)

---

## 🚀 Quick Start

> Les exemples ci-dessous utilisent l'environnement **prod** via `prod.tfvars`.

### Prérequis

- Terraform >= 1.5
- AWS CLI configuré (`aws configure`)
- Droits AWS : VPC, EC2, RDS, S3, DynamoDB, IAM, KMS, SSM

---

### 1. Configurer les variables

Remplir `prod.tfvars` avant tout déploiement :

```hcl
environment          = "prod"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

instance_type_frontend = "t3.micro"
instance_type_backend  = "t3.micro"

db_name             = "ecommerce"
db_username         = "admin"
db_password         = "CHANGEME"
engine_db           = "postgres"
engineversion_db    = "17.6"
instanceclass_db    = "db.t3.micro"
storage_db          = 20
storagetype_db      = "gp3"
backup_retention_db = 7
```

> ⚠️ `prod.tfvars` est dans `.gitignore` — ne jamais le committer (contient le mot de passe DB)

---

### 2. Bootstrap du remote state (première fois uniquement)

```bash
terraform init
terraform apply -target=module.state_backend -var-file="prod.tfvars"
terraform init -migrate-state
```

> Crée le bucket S3 + table DynamoDB, puis migre le state local vers S3.
> À faire **une seule fois** avant le déploiement complet.

---

### 3. Déployer l'infrastructure complète

```bash
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

---

### Détruire

```bash
terraform destroy -var-file="prod.tfvars"
```

> ⚠️ Vider les buckets S3 manuellement avant le destroy :
> ```bash
> aws s3 rm s3://prod-ecommerce-storage-qwerasfd --recursive
> aws s3 rm s3://prod-ecommerce-logs-qwerasfd --recursive
> aws s3 rm s3://prod-terraform-state-qwerasfd --recursive
> ```

---

## 🔐 Sécurité

### Mesures appliquées

✅ **IMDSv2 obligatoire** : `http_tokens = "required"` sur toutes les EC2 (protection SSRF)
✅ **0 accès SSH** : aucune key pair, accès via AWS SSM Session Manager uniquement
✅ **EBS chiffrés** : `encrypted = true` sur tous les volumes root (gp3)
✅ **RDS chiffrée** : KMS Customer Managed Key, pas d'IP publique
✅ **IAM least privilege** : policy `AmazonSSMManagedInstanceCore` uniquement
✅ **Security Groups en couches** : Internet → Frontend → Backend → RDS
✅ **VPC Endpoints SSM** : trafic SSM sans passer par Internet Gateway
✅ **Remote state sécurisé** : S3 AES-256 + versioning + DynamoDB lock

### Flux réseau autorisés

| Source | Destination | Port | Protocole |
|---|---|---|---|
| Internet | EC2 Frontend | 80 / 443 | TCP |
| SG Frontend | SG Backend | 3000 | TCP |
| SG Backend | RDS | 5432 | TCP |
| EC2 (tous) | VPC Endpoints SSM | 443 | TCP |

---

## 📦 Ressources AWS provisionnées

| Ressource | Description |
|---|---|
| `aws_vpc` | VPC 10.0.0.0/16 |
| `aws_subnet` × 4 | 2 public + 2 private (us-east-1a/b) |
| `aws_internet_gateway` | IGW attaché au VPC |
| `aws_route_table` | Tables de routage public / private |
| `aws_security_group` × 4 | Frontend, Backend, RDS, VPC Endpoints |
| `aws_instance` × 4 | 2 Frontend (public) + 2 Backend (private) |
| `aws_db_instance` | RDS PostgreSQL 17.6 (privé, KMS, backup 7j) |
| `aws_kms_key` | CMK pour chiffrement RDS |
| `aws_iam_role` + `aws_iam_instance_profile` | Rôle SSM pour les EC2 |
| `aws_vpc_endpoint` × 3 | ssm + ssmmessages + ec2messages |
| `aws_s3_bucket` × 3 | App storage + logs + terraform state |
| `aws_dynamodb_table` | State lock |

---

## 📁 Structure

```
stack_ecommerce/
│
├── main.tf             ← Point d'entrée : appel de tous les modules
├── providers.tf        ← AWS provider + backend S3 remote state
├── variables.tf        ← Variables globales
├── outputs.tf          ← Exports : RDS endpoint, VPC id, subnet ids...
├── prod.tfvars         ← Valeurs prod (⚠️ gitignored)
│
└── modules/
    ├── network/        ← VPC, subnets x4, IGW, route tables
    ├── security/       ← Security Groups (frontend, backend, rds, endpoints)
    ├── compute/        ← EC2 frontend x2 + backend x2
    ├── iam/            ← IAM Role + Instance Profile SSM
    ├── database/       ← RDS PostgreSQL + subnet group + KMS
    ├── endpoint/       ← VPC Endpoints SSM x3
    ├── storage/        ← S3 app + S3 logs (chiffrement, versioning, lifecycle)
    └── state_backend/  ← S3 tfstate + DynamoDB lock (bootstrap uniquement)
```

---

## 🐛 Troubleshooting

**`terraform init` échoue sur le backend S3**
```bash
# Le bucket n'existe pas encore → faire le bootstrap d'abord
terraform apply -target=module.state_backend -var-file="prod.tfvars"
terraform init -migrate-state
```

**EC2 injoignable via SSM**
```bash
# Vérifier que les VPC Endpoints SSM sont actifs
aws ec2 describe-vpc-endpoints \
  --filters "Name=service-name,Values=com.amazonaws.us-east-1.ssm"

# Vérifier que l'Instance Profile est attaché
aws ec2 describe-instances \
  --query "Reservations[].Instances[].IamInstanceProfile"
```

**`terraform destroy` bloqué sur les buckets S3**
```bash
# Les buckets non vides ne peuvent pas être détruits automatiquement
aws s3 rm s3://prod-ecommerce-storage-qwerasfd --recursive
aws s3 rm s3://prod-ecommerce-logs-qwerasfd --recursive
aws s3 rm s3://prod-terraform-state-qwerasfd --recursive
```

---

## 🔭 Axes d'évolution

- [ ] ALB devant les EC2 Frontend (SSL termination + health checks)
- [ ] Auto Scaling Group (scale in/out selon charge)
- [ ] RDS Multi-AZ (failover automatique)
- [ ] Pipeline CI/CD : `terraform fmt` + `validate` + `plan` sur PR (GitHub Actions)
- [ ] Ansible : provisioning et hardening CIS des EC2 post-déploiement

---

## 👤 Auteur

**Vincent JOAQUIM**