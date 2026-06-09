#!/usr/bin/env sh

# SQLite Datenbank-Datei erstellen falls nicht vorhanden
if [ ! -f "/app/data/database.sqlite" ]; then
    echo "📝 Erstelle SQLite DB ..."
    mkdir -p /app/data
    touch /app/data/database.sqlite
fi

echo "📊 Migration ..."
php artisan migrate --force 2>&1 || echo "Migration fehlgeschlagen"

echo "👤 Seeding ..."
php artisan db:seed --force 2>&1 || echo "Seeding fehlgeschlagen"

echo "🌐 Starte Nginx + PHP-FPM ..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
