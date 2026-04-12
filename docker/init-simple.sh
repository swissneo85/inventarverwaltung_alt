#!/bin/sh
set -e

# Create SQLite DB if not exists
if [ ! -f /app/data/database.sqlite ]; then
    touch /app/data/database.sqlite
    chown www-data:www-data /app/data/database.sqlite
fi

# Generate APP_KEY if needed
if [ -z "$APP_KEY" ]; then
    export APP_KEY="base64:$(openssl rand -base64 32)"
fi

# Run migrations
php artisan migrate --force || true
php artisan db:seed --force || true

# Start services
exec /usr/bin/supervisord -c /etc/supervisord.conf