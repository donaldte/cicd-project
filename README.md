# 🚀 Django REST API - CI/CD avec GitHub Actions & AWS

[![Django CI/CD](https://github.com/ton-org/ton-repo/actions/workflows/main.yml/badge.svg)](https://github.com/ton-org/ton-repo/actions)
[![codecov](https://codecov.io/gh/ton-org/ton-repo/branch/main/graph/badge.svg)](https://codecov.io/gh/ton-org/ton-repo)

Un projet Django REST Framework avec pipeline CI/CD professionnel automatisant le testing, building et déploiement sur AWS avec Docker.

## 📋 Table des matières

- [Architecture](#-architecture)
- [Pré-requis](#-pré-requis)
- [Installation Locale](#-installation-locale)
- [Configuration AWS](#-configuration-aws)
- [Configuration GitHub](#-configuration-github)
- [Déploiement](#-déploiement)
- [Environnements](#-environnements)
- [Dépannage](#-dépannage)
- [Structure du Projet](#-structure-du-projet)

## 🏗 Architecture

```mermaid
graph TB
    A[Code GitHub] --> B[GitHub Actions CI/CD]
    B --> C{Tests & Quality}
    C --> D[Build Docker]
    D --> E[Push ECR]
    E --> F{Environnement}
    F --> G[🟢 Development]
    F --> H[🟡 Staging]
    F --> I[🔴 Production]
    G --> J[EC2 Dev]
    H --> K[EC2 Staging]
    I --> L[EC2 Production]
```

## ⚙️ Pré-requis

Avant de commencer, assurez-vous d'avoir :

### Outils requis
- **Git** - [Download](https://git-scm.com/downloads)
- **Python 3.11+** - [Download](https://www.python.org/downloads/)
- **Docker** - [Download](https://docs.docker.com/get-docker/)
- **Docker Compose** - [Install](https://docs.docker.com/compose/install/)
- **AWS CLI** - [Install](https://aws.amazon.com/cli/)

### Comptes requis
- ✅ **GitHub Account** - [Sign up](https://github.com)
- ✅ **AWS Account** - [Sign up](https://aws.amazon.com)
- ✅ **Docker Hub** (optionnel) - [Sign up](https://hub.docker.com)

## 🛠 Installation Locale

### 1. Cloner le projet
```bash
git clone https://github.com/donaldte/cicd-project.git
cd django-rest-aws
```

### 2. Configuration de l'environnement
```bash
# Copier le template d'environnement
cp .env.example .env.development

# Générer un secret Django sécurisé
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Éditez le fichier `.env.development` :
```bash
DEBUG=True
DJANGO_SECRET_KEY=votre-secret-key-generee
POSTGRES_DB=django_app_dev
POSTGRES_USER=dev_user
POSTGRES_PASSWORD=dev_password_secure
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
ALLOWED_HOSTS=localhost,127.0.0.1
```

### 3. Démarrer avec Docker
```bash
# Construire et lancer les containers
docker-compose -f docker-compose.dev.yml up --build

# Ou en arrière-plan
docker-compose -f docker-compose.dev.yml up -d
```

### 4. Vérifier l'installation
Ouvrez votre navigateur sur :
- 🌐 **Application** : http://localhost:8000
- 📚 **API Books** : http://localhost:8000/api/books/
- 🗃️ **Admin Django** : http://localhost:8000/admin

### 5. Commandes utiles en développement
```bash
# Accéder au container Django
docker-compose exec web bash

# Lancer les tests
docker-compose exec web python manage.py test

# Créer un superuser
docker-compose exec web python manage.py createsuperuser

# Voir les logs
docker-compose logs -f web
```

## ☁️ Configuration AWS

### 1. Créer un utilisateur IAM
Allez dans **AWS Console > IAM > Users** et créez un nouvel utilisateur :

**Permissions nécessaires :**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:*",
                "ec2:*",
                "s3:*",
                "iam:PassRole"
            ],
            "Resource": "*"
        }
    ]
}
```

### 2. Créer une instance EC2
**Configuration recommandée :**
- **AMI** : Ubuntu Server 22.04 LTS
- **Instance Type** : t3.medium (2GB RAM minimum)
- **Storage** : 20GB SSD
- **Security Group** : Ouvrir les ports 22, 80, 443, 8000

**Commande de setup sur EC2 :**
```bash
# Se connecter à l'EC2
ssh -i votre-cle.pem ubuntu@votre-ip-ec2

# Installer Docker
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Installer Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Ajouter l'utilisateur au groupe Docker
sudo usermod -aG docker ubuntu

# Redémarrer la session
exit
ssh -i votre-cle.pem ubuntu@votre-ip-ec2
```

### 3. Créer un repository ECR
```bash
aws ecr create-repository --repository-name django-rest-app --region eu-west-1
```

## ⚙️ Configuration GitHub

### 1. Créer les Environments
Allez dans **Settings > Environments** et créez ces environnements :

#### 🟢 Development
- **Name** : `development`
- **Deployment branches** : `develop`
- **Protection rules** : Aucune

#### 🟡 Staging  
- **Name** : `staging`
- **Deployment branches** : `main`
- **Protection rules** : 1 approbation requise

#### 🔴 Production
- **Name** : `production` 
- **Deployment branches** : `main`
- **Protection rules** : 2 approbations requises

### 2. Configurer les Variables GitHub
Allez dans **Settings > Secrets and variables > Actions**

#### Variables Globales (Variables) :
```bash
PROJECT_NAME: "django-rest-aws"
PYTHON_VERSION: "3.11"
POSTGRES_VERSION: "13"
ECR_REPOSITORY: "django-rest-app"
AWS_REGION: "eu-west-1"
SLACK_CHANNEL: "#deployments"
```

#### Secrets Globaux (Secrets) :
```bash
AWS_ACCESS_KEY_ID: "AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_ACCESS_KEY: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
```

### 3. Secrets par Environnement

#### 🟢 Development (Environment: development > Secrets) :
```bash
DJANGO_SECRET_KEY: "votre-secret-dev"
POSTGRES_PASSWORD: "password-dev"
AWS_EC2_HOST_DEV: "ec2-12-34-56-78.eu-west-1.compute.amazonaws.com"
AWS_SSH_USER_DEV: "ubuntu"
AWS_SSH_PRIVATE_KEY_DEV: "-----BEGIN RSA PRIVATE KEY-----\n..."
```

#### 🟡 Staging (Environment: staging > Secrets) :
```bash
DJANGO_SECRET_KEY: "votre-secret-staging" 
POSTGRES_PASSWORD: "password-staging"
AWS_EC2_HOST_STAGING: "ec2-98-76-54-32.eu-west-1.compute.amazonaws.com"
AWS_SSH_USER_STAGING: "ubuntu"
AWS_SSH_PRIVATE_KEY_STAGING: "-----BEGIN RSA PRIVATE KEY-----\n..."
SLACK_WEBHOOK_STAGING: "https://hooks.slack.com/services/..."
```

#### 🔴 Production (Environment: production > Secrets) :
```bash
DJANGO_SECRET_KEY: "votre-secret-production-tres-securise"
POSTGRES_PASSWORD: "password-production-tres-securise"
AWS_EC2_HOST_PROD: "ec2-11-22-33-44.eu-west-1.compute.amazonaws.com"
AWS_SSH_USER_PROD: "ubuntu" 
AWS_SSH_PRIVATE_KEY_PROD: "-----BEGIN RSA PRIVATE KEY-----\n..."
SLACK_WEBHOOK_PROD: "https://hooks.slack.com/services/..."
SENTRY_DSN_PROD: "https://votre-sentry-dsn@example.com"
```

## 🚀 Déploiement

### Workflow de déploiement automatique

| Branche | Environnement | Déclencheur | Process |
|---------|---------------|-------------|---------|
| `develop` | 🟢 **Development** | Push | Déploiement automatique |
| `main` | 🟡 **Staging** | Merge PR | Déploiement + 1 approbation |
| `main` | 🔴 **Production** | Release | Déploiement + 2 approbations |

### 1. Premier déploiement manuel

```bash
# Préparer les fichiers de déploiement
cp docker-compose.prod.yml.example docker-compose.production.yml
cp .env.prod.example .env.production

# Configurer les variables dans .env.production
nano .env.production

# Copier vers le serveur
scp -i votre-cle.pem docker-compose.production.yml .env.production ubuntu@votre-ec2:~/app/

# Déployer manuellement
ssh -i votre-cle.pem ubuntu@votre-ec2
cd app
docker-compose -f docker-compose.production.yml up -d
```

### 2. Déploiement via GitHub Actions

Le pipeline s'exécute automatiquement :

1. **Tests** → Tests unitaires, linting, sécurité
2. **Build** → Construction des images Docker
3. **Push** → Envoi vers AWS ECR  
4. **Deploy** → Déploiement sur EC2
5. **Health Check** → Vérification du déploiement

### 3. Vérifier le déploiement

```bash
# Vérifier les containers
docker ps

# Voir les logs
docker-compose -f docker-compose.production.yml logs -f

# Test de santé
curl http://localhost/api/books/
```

## 🌍 Environnements

### 🟢 Development
- **URL** : http://dev.votre-domaine.com
- **Base de données** : PostgreSQL locale
- **Debug** : Activé
- **Usage** : Développement features

### 🟡 Staging  
- **URL** : https://staging.votre-domaine.com
- **Base de données** : PostgreSQL staging
- **Debug** : Désactivé
- **Usage** : Tests utilisateurs

### 🔴 Production
- **URL** : https://votre-domaine.com
- **Base de données** : PostgreSQL production
- **Debug** : Désactivé
- **Usage** : Clients réels

## 🔧 Dépannage

### Problèmes courants

#### ❌ "Permission denied" sur EC2
```bash
# Vérifier les permissions de la clé SSH
chmod 400 votre-cle.pem

# Vérifier l'utilisateur SSH
ssh -i votre-cle.pem ubuntu@ec2-ip
```

#### ❌ Erreurs de connexion Docker
```bash
# Vérifier que Docker tourne
sudo systemctl status docker

# Relancer Docker
sudo systemctl restart docker
```

#### ❌ ECR Login failed
```bash
# Vérifier les credentials AWS
aws configure list

# Tester l'accès ECR
aws ecr describe-repositories --region eu-west-1
```

#### ❌ Health check failed
```bash
# Vérifier les logs de l'application
docker-compose logs web

# Vérifier la base de données
docker-compose exec db psql -U votre-user -d votre-db
```

### Commandes de debug utiles

```bash
# Nettoyer les containers
docker system prune -a

# Voir l'espace disque
df -h

# Voir la mémoire
free -h

# Surveillance des logs
docker-compose logs -f --tail=50
```

## 📁 Structure du Projet

```
django-rest-aws/
├── .github/
│   ├── workflows/
│   │   ├── main.yml              # Workflow principal
│   │   └── includes/             # Modules réutilisables
│   ├── scripts/                  # Scripts utilitaires
│   └── environments/             # Configuration environnements
├── app/
│   ├── Dockerfile               # Image Django
│   ├── docker-compose.yml       # Compose développement
│   ├── requirements.txt         # Dépendances Python
│   ├── manage.py
│   └── myproject/
│       ├── settings/
│       │   ├── base.py          # Configuration de base
│       │   ├── development.py   # Dev settings
│       │   └── production.py    # Prod settings
│       └── api/                 # Application REST
├── nginx/
│   ├── Dockerfile              # Image Nginx
│   └── nginx.conf             # Configuration Nginx
├── scripts/
│   ├── deploy.sh              # Script de déploiement
│   └── health-check.sh        # Vérification santé
└── docs/                      # Documentation
```

## 🛡️ Sécurité

### Bonnes pratiques implémentées

- ✅ **Secrets managés** via GitHub Secrets
- ✅ **Environnements isolés** (dev/staging/prod)
- ✅ **Scan de sécurité** avec Snyk et Bandit
- ✅ **Reviews obligatoires** pour la production
- ✅ **Health checks** automatiques
- ✅ **Rollback** via tags Docker

### Rotation des secrets
```bash
# Générer un nouveau secret Django
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# Mettre à jour dans GitHub Secrets
# Settings > Secrets > DJANGO_SECRET_KEY
```

## 📞 Support

### Documentation supplémentaire
- [📚 Django Documentation](https://docs.djangoproject.com)
- [🐳 Docker Documentation](https://docs.docker.com)
- [☁️ AWS ECR Documentation](https://aws.amazon.com/ecr/)
- [⚙️ GitHub Actions](https://docs.github.com/en/actions)

### Problèmes connus
- Le health check peut échouer si la base de données met trop de temps à démarrer
- Les builds Docker peuvent échouer si le cache ECR est corrompu

### Contribuer
1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

**🚀 Vous êtes maintenant prêt à déployer votre application Django avec un pipeline CI/CD professionnel !**

Pour toute question, ouvrez une [issue](https://github.com/donaldte/cicd-project/issues) ou consultez la documentation.