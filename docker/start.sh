#!/usr/bin/env sh

# Create DB if not exists
if [ ! -f "/app/data/database.sqlite" ]; then
    echo "📝 Creating SQLite DB ..."
    mkdir -p /app/data
    touch /app/data/database.sqlite
    php artisan migrate --force
    php artisan db:seed --force
fi

# Laravel optimize
php artisan package:discover --ansi 2>/dev/null || true
php artisan optimize 2>/dev/null || true
php artisan config:clear 2>/dev/null || true

echo "🌐 Starting Nginx + PHP-FPM ..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
