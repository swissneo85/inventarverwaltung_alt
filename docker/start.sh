#!/usr/bin/env sh

# Fix permissions on storage (as root)
mkdir -p /var/www/html/storage/logs /var/www/html/storage/framework/cache /var/www/html/storage/framework/sessions /var/www/html/storage/framework/views /var/www/html/bootstrap/cache
chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache

# Create DB if not exists
if [ ! -f "/app/data/database.sqlite" ]; then
    echo "📝 Creating SQLite DB ..."
    mkdir -p /app/data
    touch /app/data/database.sqlite
    chmod 777 /app/data/database.sqlite
    php artisan migrate --force 2>&1 || echo "MIGRATE FAILED"
    php artisan db:seed --force 2>&1 || echo "SEED FAILED"
fi

# Laravel optimize
php artisan package:discover --ansi 2>/dev/null || true
php artisan optimize 2>/dev/null || true
php artisan config:clear 2>/dev/null || true

echo "🌐 Starting Nginx + PHP-FPM (as root) ..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
