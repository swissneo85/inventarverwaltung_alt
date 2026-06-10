#!/usr/bin/env sh
set -e

echo "🚀 Starte Inventarverwaltung..."

# Ensure www-data user exists (Alpine fix)
if ! id -u www-data > /dev/null 2>&1; then
    adduser -D -u 33 -g www-data www-data 2>/dev/null || true
fi

# Fix permissions
mkdir -p /var/www/html/storage/logs /var/www/html/storage/framework/cache \
    /var/www/html/storage/framework/sessions /var/www/html/storage/framework/views \
    /var/www/html/bootstrap/cache /app/data
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true
chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache /app/data

# Ensure APP_KEY is set (critical for Laravel)
if [ -z "$APP_KEY" ]; then
    echo "⚠️  APP_KEY nicht gesetzt! Generiere automatisch..."
    export APP_KEY="base64:$(openssl rand -base64 32)"
    echo "   APP_KEY=$APP_KEY"
fi

echo "   APP_KEY ist konfiguriert"

# Environment checks
if [ -z "$DB_CONNECTION" ]; then
    export DB_CONNECTION=sqlite
fi
if [ -z "$DB_DATABASE" ]; then
    export DB_DATABASE=/app/data/database.sqlite
fi
if [ -z "$SESSION_DRIVER" ]; then
    export SESSION_DRIVER=file
fi

# Create SQLite DB if missing
if [ ! -f "$DB_DATABASE" ]; then
    echo "📝 Erstelle SQLite Datenbank..."
    mkdir -p "$(dirname "$DB_DATABASE")"
    touch "$DB_DATABASE"
    chmod 666 "$DB_DATABASE"
    
    echo "   Führe Migrationen aus..."
    cd /var/www/html
    php artisan migrate --force --no-ansi 2>&1 || { echo "   ❌ Migration fehlgeschlagen"; }
    
    echo "   Führe Seeder aus..."
    php artisan db:seed --force --no-ansi 2>&1 || { echo "   ❌ Seed fehlgeschlagen"; }
    
    echo "   ✅ Datenbank initialisiert"
else
    echo "   📁 Datenbank existiert bereits"
    
    # Verify DB has tables; if somehow empty, re-seed
    TABLE_COUNT=$(sqlite3 "$DB_DATABASE" "SELECT count(name) FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';" 2>/dev/null || echo "0")
    if [ "$TABLE_COUNT" -lt "5" ]; then
        echo "   ⚠️  Datenbank scheint leer. Führe Migrationen + Seeder erneut aus..."
        cd /var/www/html
        php artisan migrate --force --no-ansi 2>&1 || true
        php artisan db:seed --force --no-ansi 2>&1 || true
    fi
fi

# Ensure storage link exists
php artisan storage:link --force 2>/dev/null || true

echo "🌐 Starte Nginx + PHP-FPM..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
