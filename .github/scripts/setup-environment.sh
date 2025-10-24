#!/bin/bash

set -e

echo "🔧 Setting up environment..."

# Create environment files
if [ "$ENVIRONMENT" = "production" ]; then
    cat > .env.prod << EOF
DEBUG=False
DJANGO_SECRET_KEY=$PRODUCTION_SECRET_KEY
POSTGRES_DB=prod_db
POSTGRES_USER=prod_user
POSTGRES_PASSWORD=$PRODUCTION_DB_PASSWORD
ALLOWED_HOSTS=$PRODUCTION_HOSTS
ECR_REGISTRY=$ECR_REGISTRY
ECR_REPOSITORY=$ECR_REPOSITORY
AWS_REGION=$AWS_REGION
EOF
else
    cat > .env.dev << EOF
DEBUG=True
DJANGO_SECRET_KEY=dev-secret-key
POSTGRES_DB=dev_db
POSTGRES_USER=dev_user
POSTGRES_PASSWORD=dev_password
ALLOWED_HOSTS=localhost,127.0.0.1
ECR_REGISTRY=$ECR_REGISTRY
ECR_REPOSITORY=$ECR_REPOSITORY
AWS_REGION=$AWS_REGION
EOF
fi

echo "✅ Environment setup completed"