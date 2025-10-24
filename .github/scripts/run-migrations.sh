#!/bin/bash

set -e

echo "🗃️ Running database migrations..."

# Wait for database to be ready
while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
  sleep 1
done

echo "📦 Database is ready, running migrations..."

cd /app

# Run Django migrations
python manage.py makemigrations --noinput
python manage.py migrate --noinput

# Create superuser if not exists
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(username='admin').exists() or User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | python manage.py shell

echo "✅ Migrations completed successfully"