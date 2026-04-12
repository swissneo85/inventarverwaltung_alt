#!/bin/sh
set -e

echo "Starting Inventarverwaltung..."

# Initialize database if not exists
if [ ! -f /app/data/database.sqlite ]; then
    echo "Initializing SQLite database..."
    touch /app/data/database.sqlite
    chown www-data:www-data /app/data/database.sqlite
fi

# Generate APP_KEY if not set
if [ -z "$APP_KEY" ]; then
    echo "Generating APP_KEY..."
    export APP_KEY="base64:$(openssl rand -base64 32)"
fi

# Run migrations
echo "Running migrations..."
php artisan migrate --force --no-interaction || true

# Seed database (create admin user)
echo "Seeding database..."
php artisan db:seed --force --no-interaction || true

# Clear cache
php artisan cache:clear --no-interaction || true
php artisan config:clear --no-interaction || true

# Set permissions
chown -R www-data:www-data /var/www/html/storage
chown -R www-data:www-data /app/data

echo "Starting services..."

# Start supervisor (manages nginx + php-fpm)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf