#!/usr/bin/env sh

# Ensure www-data user exists (Alpine fix)
if ! id -u www-data > /dev/null 2>&1; then
    adduser -D -u 33 -g www-data www-data 2>/dev/null || true
fi

# Fix permissions on storage (777 to be sure)
mkdir -p /var/www/html/storage/logs /var/www/html/storage/framework/cache /var/www/html/storage/framework/sessions /var/www/html/storage/framework/views /var/www/html/bootstrap/cache
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true
chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true

# Also fix for root user fallback
chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache

# Create DB if not exists
if [ ! -f "/app/data/database.sqlite" ]; then
    echo "📝 Creating SQLite DB ..."
    mkdir -p /app/data
    touch /app/data/database.sqlite
    chmod 666 /app/data/database.sqlite
    php artisan migrate --force 2>&1 || echo "MIGRATE FAILED"
    php artisan db:seed --force 2>&1 || echo "SEED FAILED"
fi

# Laravel optimize
php artisan package:discover --ansi 2>/dev/null || true
php artisan optimize 2>/dev/null || true
php artisan config:clear 2>/dev/null || true

echo "🌐 Starting Nginx + PHP-FPM ..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
