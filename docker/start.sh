#!/usr/bin/env sh

# Fix permissions on storage
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache || true
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache || true

# TEMP: Debug mode ON to see real errors
export APP_DEBUG=true

# Create DB if not exists
if [ ! -f "/app/data/database.sqlite" ]; then
    echo "📝 Creating SQLite DB ..."
    mkdir -p /app/data
    touch /app/data/database.sqlite
    php artisan migrate --force > /var/www/html/storage/logs/migrate.log 2>&1 || echo "MIGRATE FAILED! Check storage/logs/migrate.log"
    php artisan db:seed --force > /var/www/html/storage/logs/seed.log 2>&1 || echo "SEED FAILED! Check storage/logs/seed.log"
fi

# Laravel optimize (with debug so we see errors)
php artisan package:discover --ansi 2>/dev/null || true
php artisan optimize 2>/dev/null || true
php artisan config:clear 2>/dev/null || true

echo "🌐 Starting Nginx + PHP-FPM ..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
