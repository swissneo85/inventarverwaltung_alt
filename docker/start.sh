#!/usr/bin/env sh
echo "⚡️ Migration ..."
php artisan migrate --force 2>&1 || echo "Migration fehleschlagen, vermutlich normal bei erstem Start."

echo "⚇️ Seeding ..."
php artisan db:seed --force 2>&1 || echo "Seeding fehlschlagen, vermutlich normal bei erstem Start."

echo "⚡️ Starte Nginx + PHP-FPM ..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
