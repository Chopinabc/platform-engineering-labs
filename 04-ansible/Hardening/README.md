# Ansible Hardening - CIS Benchmark Level 1

Playbook Ansible de hardening automatisé pour serveurs Linux (RHEL/CentOS),
conforme au CIS Benchmark Level 1. Déployé sur instances AWS EC2 via
inventaire dynamique.

---

## 🏗️ Architecture

```
Ansible Controller
    └── Inventaire dynamique AWS EC2 (aws_ec2.yml)
        └── Role hardening → 4 instances RHEL (t3.micro)
            ├── SSH hardening
            ├── Sysctl (kernel security)
            ├── Fail2ban (brute force protection)
            └── Auditd (audit trail)
```

**Stack :**
- **Ansible** : 2.x + collection amazon.aws
- **OS cible** : RHEL 9 / Amazon Linux 2023
- **Cloud** : AWS EC2 (us-east-1)
- **Inventaire** : Dynamique via tags AWS (`env: lab`)

---

## 🔐 Mesures de sécurité appliquées

### SSH
✅ Connexion root désactivée (`PermitRootLogin no`)  
✅ Authentification par mot de passe désactivée  
✅ Seul le compte de service `deployment` autorisé  
✅ MaxAuthTries : 4  
✅ ClientAliveCountMax : 0  
✅ X11Forwarding et TCPForwarding désactivés  

### Kernel (sysctl)
✅ Reverse path filtering activé (anti-spoofing)  
✅ SYN cookies activés (anti SYN flood)  
✅ IP forwarding désactivé  
✅ ICMP redirects désactivés  
✅ Source routing désactivé  
✅ ASLR activé (kernel.randomize_va_space: 2)  

### Fail2ban
✅ Protection SSH brute force  
✅ Bannissement après 5 tentatives en 60 secondes  
✅ Durée de bannissement : 1 heure  

### Auditd (CIS Level 1)
✅ Surveillance des connexions et sessions  
✅ Traçabilité des élévations de privilèges (sudo)  
✅ Surveillance des modifications de comptes  
✅ Audit des appels système sensibles (chmod, chown)  
✅ Règles immuables en production (`-e 2`)  

---

## 🚀 Quick Start

### Prérequis

```bash
# Python + boto3 (inventaire dynamique AWS)
pip install boto3 botocore

# Collection AWS Ansible
ansible-galaxy collection install amazon.aws
```

### Credentials AWS

```bash
export AWS_ACCESS_KEY_ID="your_key"
export AWS_SECRET_ACCESS_KEY="your_secret"
export AWS_DEFAULT_REGION="us-east-1"
```

### Lancer le playbook

```bash
# Vérifier la connectivité
ansible -i inventory/aws_ec2.yml all \
  --private-key ~/.ssh/your-key \
  --user ec2-user \
  -m ping

# Dry-run (simulation)
ansible-playbook -i inventory/aws_ec2.yml playbook.yml \
  --private-key ~/.ssh/your-key \
  --user ec2-user \
  --check

# Déploiement
ansible-playbook -i inventory/aws_ec2.yml playbook.yml \
  --private-key ~/.ssh/your-key \
  --user ec2-user
```

---

## 📁 Structure

```
Hardening/
├── inventory/
│   └── aws_ec2.yml          # Inventaire dynamique AWS (filtre tag env:lab)
├── group_vars/
│   └── all/
│       └── vars.yml         # Variables SSH, sysctl, fail2ban
├── playbook.yml             # Point d'entrée
└── roles/
    └── hardening/
        ├── defaults/
        │   └── main.yml     # Valeurs par défaut (priorité basse)
        ├── handlers/
        │   └── main.yml     # reload sshd, restart fail2ban, reload auditd
        ├── tasks/
        │   ├── main.yml     # Orchestrateur - détection OS
        │   ├── RedHat.yml   # Tasks RHEL (dnf, EPEL, swap)
        │   └── Debian.yml   # Tasks Debian (apt)
        └── templates/
            ├── auditd.local.j2   # Règles auditd CIS Level 1
            └── jail.local.j2     # Config fail2ban
```

---

## ⚠️ Écarts CIS documentés

| Règle | Statut | Justification |
|-------|--------|---------------|
| Sudo sans password (NOPASSWD) | Écart assumé | Compte de service Ansible - automatisation requiert sudo non interactif. Compensé par authentification par clé SSH uniquement et audit auditd. |
| Swap activé sur t3.micro | Spécifique lab | t3.micro (1GB RAM) - swap nécessaire pour l'installation des packages. Non applicable en production (instance correctement dimensionnée). |

---

## 🐛 Troubleshooting

**Inventaire vide**
```bash
# Vérifier les credentials AWS
aws sts get-caller-identity

# Vérifier boto3
python3 -c "import boto3; print('OK')"
```

**OOM lors de l'installation (t3.micro)**
```bash
# Le playbook active automatiquement 1GB de swap avant l'installation
# Voir tasks/RedHat.yml - section "Spéciale t3.micro"
```

**Permission denied (publickey)**
```bash
# Vérifier le user et la clé privée
ansible ... --user ec2-user --private-key ~/.ssh/your-key
```

---

## 👤 Auteur

**Vincent JOAQUIM**  