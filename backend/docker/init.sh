#!/bin/bash
set -e

echo "Starting Laravel initialization..."

# Wait for database
until nc -z db 3306; do
    echo "Waiting for database..."
    sleep 2
done

echo "Database is ready!"

# Generate app key if not set
if [ -z "$APP_KEY" ]; then
    echo "Generating APP_KEY..."
    php artisan key:generate --force
fi

# Run migrations
echo "Running migrations..."
php artisan migrate --force

# Run seeders (creates admin user)
echo "Running seeders..."
php artisan db:seed --force

# Link storage
echo "Linking storage..."
php artisan storage:link --force || true

# Clear cache
echo "Clearing cache..."
php artisan cache:clear
php artisan config:clear
php artisan route:clear

echo "Laravel initialization complete!"