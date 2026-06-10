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

# ============================================
# .env Datei konfigurieren (KRITISCH!)
# ============================================
ENV_FILE="/var/www/html/.env"

# Falls .env fehlt, erstelle eine
if [ ! -f "$ENV_FILE" ]; then
    echo "📝 Erstelle .env Datei..."
    cat > "$ENV_FILE" <<EOF
APP_NAME=Inventarverwaltung
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://localhost:3004
DB_CONNECTION=sqlite
DB_DATABASE=/app/data/database.sqlite
SESSION_DRIVER=file
SESSION_LIFETIME=120
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
LOG_CHANNEL=errorlog
LOG_LEVEL=warning
EOF
fi

# APP_KEY in .env schreiben (wichtig für Sanctum!)
if [ -n "$APP_KEY" ]; then
    # Entferne alten APP_KEY und setze neuen
    sed -i '/^APP_KEY=/d' "$ENV_FILE"
    echo "APP_KEY=${APP_KEY}" >> "$ENV_FILE"
    echo "   APP_KEY aus Umgebungsvariable gesetzt"
elif ! grep -q '^APP_KEY=.' "$ENV_FILE"; then
    # Generiere APP_KEY falls leer
    echo "⚠️  APP_KEY nicht gesetzt! Generiere automatisch..."
    NEW_KEY="base64:$(openssl rand -base64 32)"
    sed -i '/^APP_KEY=/d' "$ENV_FILE"
    echo "APP_KEY=${NEW_KEY}" >> "$ENV_FILE"
    echo "   APP_KEY=${NEW_KEY}"
fi

# Umgebungsvariablen in .env schreiben (für Docker-Compose Kompatibilität)
if [ -n "$APP_URL" ]; then
    sed -i '/^APP_URL=/d' "$ENV_FILE"
    echo "APP_URL=${APP_URL}" >> "$ENV_FILE"
fi

# DB Konfiguration in .env sicherstellen
sed -i '/^DB_CONNECTION=/d' "$ENV_FILE"
echo "DB_CONNECTION=sqlite" >> "$ENV_FILE"
sed -i '/^DB_DATABASE=/d' "$ENV_FILE"
echo "DB_DATABASE=/app/data/database.sqlite" >> "$ENV_FILE"

# Session Driver
sed -i '/^SESSION_DRIVER=/d' "$ENV_FILE"
echo "SESSION_DRIVER=file" >> "$ENV_FILE"

echo "   ✅ .env konfiguriert"

# Laravel Config Cache leeren (damit .env neu gelesen wird)
cd /var/www/html
php artisan config:clear 2>/dev/null || true

# Create SQLite DB if missing
DB_FILE="/app/data/database.sqlite"
if [ ! -f "$DB_FILE" ]; then
    echo "📝 Erstelle SQLite Datenbank..."
    mkdir -p "$(dirname "$DB_FILE")"
    touch "$DB_FILE"
    chmod 666 "$DB_FILE"
    
    echo "   Führe Migrationen aus..."
    php artisan migrate --force --no-ansi 2>&1 || { echo "   ❌ Migration fehlgeschlagen"; }
    
    echo "   Führe Seeder aus..."
    php artisan db:seed --force --no-ansi 2>&1 || { echo "   ❌ Seed fehlgeschlagen"; }
    
    echo "   ✅ Datenbank initialisiert"
else
    echo "   📁 Datenbank existiert bereits"

    # Immer neue Migrationen ausführen (bereits ausgeführte werden übersprungen)
    echo "   Führe ausstehende Migrationen aus..."
    php artisan migrate --force --no-ansi 2>&1 || true

    # Verify DB has tables; if somehow empty, re-seed
    TABLE_COUNT=$(sqlite3 "$DB_FILE" "SELECT count(name) FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';" 2>/dev/null || echo "0")
    if [ "$TABLE_COUNT" -lt "5" ]; then
        echo "   ⚠️  Datenbank scheint leer. Führe Seeder erneut aus..."
        php artisan db:seed --force --no-ansi 2>&1 || true
    fi
fi

# Ensure storage link exists
php artisan storage:link --force 2>/dev/null || true

echo "🌐 Starte Nginx + PHP-FPM..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
