#!/bin/bash

# Attendre que la base de données soit prête
echo "Waiting for database..."
while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
  sleep 0.1
done
echo "Database started"

# Appliquer les migrations
python manage.py makemigrations
python manage.py migrate

# Collecter les fichiers statiques
python manage.py collectstatic --noinput

# Démarrer
exec "$@"