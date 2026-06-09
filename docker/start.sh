#!/usr/bin/env sh

# Check of DB exists (in case volume overwrote image)
if [ ! -f "/app/data/database.sqlite" ]; then
    echo "📝 SQL DB not found in volume. Creating ..."
    mkdir -p /app/data
    touch /app/data/database.sqlite
    php artisan migrate --force 2>&1
    php artisan db:seed --force 2>&1
else
    echo "�n SQL DB already exists."
fi

echo "𜫁 Starting Nginx + PHP-FPM ..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
