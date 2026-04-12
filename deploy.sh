#!/bin/bash
set -e

# ============================================
# Inventarverwaltung - Deployment Script
# Für Hostinger VPS / Docker-Server
# ============================================

# Farben
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════╗"
echo "║     Inventarverwaltung - Deployment       ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${NC}"

# Projektverzeichnis
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# Prüfen ob Docker läuft
echo -e "${BLUE}🔍 Prüfe Docker...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker läuft nicht! Bitte Docker starten.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker läuft${NC}"

# .env erstellen falls nicht vorhanden
if [ ! -f ".env" ]; then
    echo -e "${BLUE}📝 Erstelle .env Datei...${NC}"
    cp .env.production .env
    
    # Zufällige Passwörter generieren
    DB_PASSWORD=$(openssl rand -base64 18 | tr -d '/+=' | head -c 24)
    DB_ROOT_PASSWORD=$(openssl rand -base64 18 | tr -d '/+=' | head -c 24)
    APP_KEY="base64:$(openssl rand -base64 32)"
    
    # .env aktualisieren
    sed -i "s/DB_PASSWORD=CHANGE_THIS_PASSWORD/DB_PASSWORD=$DB_PASSWORD/" .env
    sed -i "s/DB_ROOT_PASSWORD=CHANGE_THIS_ROOT_PASSWORD/DB_ROOT_PASSWORD=$DB_ROOT_PASSWORD/" .env
    sed -i "s|APP_KEY=base64:GENERATE_A_32_CHARACTER_KEY_HERE|APP_KEY=$APP_KEY|" .env
    
    echo -e "${GREEN}✓ .env erstellt mit sicheren Passwörtern${NC}"
    echo ""
    echo -e "${BLUE}📋 Passwörter (bitte speichern!):${NC}"
    echo "   DB_PASSWORD: $DB_PASSWORD"
    echo "   DB_ROOT_PASSWORD: $DB_ROOT_PASSWORD"
    echo ""
fi

# Prüfen ob Frontend gebaut ist
if [ ! -d "frontend/dist" ]; then
    echo -e "${BLUE}🔨 Baue Frontend...${NC}"
    
    # Node.js prüfen
    if ! command -v node &> /dev/null; then
        echo -e "${BLUE}📦 Installiere Node.js...${NC}"
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash - > /dev/null
        apt-get install -y nodejs > /dev/null
    fi
    
    cd frontend
    npm install --silent
    npm run build
    cd ..
    echo -e "${GREEN}✓ Frontend gebaut${NC}"
fi

# Prüfen ob Backend Dependencies installiert sind
if [ ! -d "backend/vendor" ]; then
    echo -e "${BLUE}📦 Installiere Backend Dependencies...${NC}"
    
    # Composer prüfen
    if ! command -v composer &> /dev/null; then
        echo -e "${BLUE}📦 Installiere Composer...${NC}"
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer > /dev/null
    fi
    
    cd backend
    composer install --no-dev --optimize-autoloader --no-interaction
    cd ..
    echo -e "${GREEN}✓ Backend Dependencies installiert${NC}"
fi

# Speicherrechte
echo -e "${BLUE}🔧 Setze Dateirechte...${NC}"
mkdir -p backend/storage/logs
mkdir -p backend/storage/framework/cache
mkdir -p backend/storage/framework/sessions
mkdir -p backend/storage/framework/views
mkdir -p backend/bootstrap/cache
chmod -R 775 backend/storage
chmod -R 775 backend/bootstrap/cache
echo -e "${GREEN}✓ Dateirechte gesetzt${NC}"

# Docker starten
echo -e "${BLUE}🐳 Starte Docker Container...${NC}"
docker-compose -f docker-compose.prod.yml down > /dev/null 2>&1 || true
docker-compose -f docker-compose.prod.yml up -d

# Warten auf Datenbank
echo -e "${BLUE}⏳ Warte auf Datenbank...${NC}"
sleep 10
until docker-compose -f docker-compose.prod.yml exec -T db mariadb -u inventar -p$(grep DB_PASSWORD .env | cut -d'=' -f2) -e "SELECT 1" > /dev/null 2>&1; do
    echo "   Warte..."
    sleep 3
done
echo -e "${GREEN}✓ Datenbank bereit${NC}"

# Laravel Migrationen
echo -e "${BLUE}📊 Führe Migrationen aus...${NC}"
docker exec inventar-backend php artisan migrate --force 2>/dev/null || \
docker run --rm -v "$(pwd)/backend:/var/www/html" -w /var/www/html php:8.2-fpm-alpine php artisan migrate --force

# Seeden (Admin erstellen)
echo -e "${BLUE}👤 Erstelle Standard-Benutzer...${NC}"
docker exec inventar-backend php artisan db:seed --force 2>/dev/null || \
docker run --rm -v "$(pwd)/backend:/var/www/html" -w /var/www/html php:8.2-fpm-alpine php artisan db:seed --force || true

# Cache leeren
docker exec inventar-backend php artisan cache:clear 2>/dev/null || true
docker exec inventar-backend php artisan config:clear 2>/dev/null || true

# Nginx neustarten
docker-compose -f docker-compose.prod.yml restart nginx

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ Installation abgeschlossen!        ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}🌐 Zugriff:${NC}"
echo "   http://deine-ip-adresse"
echo ""
echo -e "${BLUE}🔑 Standard-Login:${NC}"
echo "   Benutzer: admin"
echo "   Passwort: admin123"
echo ""
echo -e "${RED}⚠️  Wichtig: Ändere sofort das Passwort!${NC}"
echo ""
echo -e "${BLUE}📌 Nützliche Befehle:${NC}"
echo "   Logs:     docker-compose -f docker-compose.prod.yml logs -f"
echo "   Stoppen:  docker-compose -f docker-compose.prod.yml down"
echo "   Neustart: docker-compose -f docker-compose.prod.yml restart"
echo ""