#!/bin/sh
php artisan migrate --force 2>/dev/null || true
php artisan db:seed --force 2>/dev/null || true
exec /usr/bin/supervisord -c /etc/supervisord.conf