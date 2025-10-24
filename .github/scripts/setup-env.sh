#!/bin/bash

set -e

echo "🔧 Setting up environment variables..."

# Function to generate random secret
generate_secret() {
    python3 -c "import secrets; print(secrets.token_urlsafe(50))"
}

ENV_FILE=".env.$1"

case $1 in
    "development")
        cat > $ENV_FILE << EOF
DEBUG=True
DJANGO_SECRET_KEY=$(generate_secret)
POSTGRES_DB=django_app_dev
POSTGRES_USER=dev_user
POSTGRES_PASSWORD=$(generate_secret)
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
ALLOWED_HOSTS=localhost,127.0.0.1
REDIS_URL=redis://localhost:6379
EOF
        ;;

    "staging")
        cat > $ENV_FILE << EOF
DEBUG=False
DJANGO_SECRET_KEY=$(generate_secret)
POSTGRES_DB=django_app_staging
POSTGRES_USER=staging_user
POSTGRES_PASSWORD=$(generate_secret)
POSTGRES_HOST=staging-db.internal.com
POSTGRES_PORT=5432
ALLOWED_HOSTS=staging.example.com
REDIS_URL=redis://staging-redis:6379
EOF
        ;;

    "production")
        echo "❌ Production environment should be set manually with secure secrets!"
        exit 1
        ;;

    *)
        echo "Usage: $0 {development|staging}"
        exit 1
        ;;
esac

echo "✅ Environment file created: $ENV_FILE"
echo "🔐 Remember to update passwords and secrets in production!"