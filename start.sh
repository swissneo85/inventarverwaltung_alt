#!/bin/bash
set -e

echo "🚀 Starte Inventarverwaltung..."

# colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Prüfen ob Docker läuft
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker läuft nicht. Bitte Docker starten."
    exit 1
fi

# Wechsel ins Projektverzeichnis
cd "$(dirname "$0")"

# .env erstellen falls nicht vorhanden
if [ ! -f ".env" ]; then
    echo -e "${BLUE}📝 Erstelle .env Datei...${NC}"
    cp .env.example .env
fi

# Container bauen
echo -e "${BLUE}🐳 Baue Docker Container...${NC}"
docker-compose build

# Container starten
echo -e "${BLUE}🐳 Starte Container...${NC}"
docker-compose up -d

# Warten bis Container bereit sind
echo -e "${BLUE}⏳ Warte auf Container...${NC}"
sleep 5

# Laravel initialisieren
echo -e "${BLUE}⚙️  Initialisiere Laravel...${NC}"

# Auf Datenbank warten
until docker-compose exec -T db mariadb -u inventar -pinventar_secret -e "SELECT 1" > /dev/null 2>&1; do
    echo "   Warte auf Datenbank..."
    sleep 2
done

echo -e "${GREEN}✓ Datenbank bereit!${NC}"

# App Key generieren
if ! docker-compose exec -T backend php artisan key:generate --force 2>/dev/null; then
    echo "   (APP_KEY bereits gesetzt)"
fi

# Migrationen
echo -e "${BLUE}📊 Führe Migrationen aus...${NC}"
docker-compose exec -T backend php artisan migrate --force

# Seed (Admin-User erstellen)
echo -e "${BLUE}👤 Erstelle Standard-Benutzer...${NC}"
docker-compose exec -T backend php artisan db:seed --force 2>/dev/null || echo "   (Seed bereits ausgeführt)"

# Cache leeren
docker-compose exec -T backend php artisan cache:clear 2>/dev/null || true
docker-compose exec -T backend php artisan config:clear 2>/dev/null || true

echo ""
echo -e "${GREEN}✅ Inventarverwaltung ist bereit!${NC}"
echo ""
echo -e "🌐 ${BLUE}Zugriff:${NC}"
echo "   Frontend (Dev): http://localhost:3000"
echo "   Backend API:    http://localhost:8080/api"
echo ""
echo -e "🔑 ${BLUE}Login-Daten:${NC}"
echo "   Admin: admin / admin123"
echo "   User:  max / password"
echo ""
echo -e "📌 ${BLUE}Befehle:${NC}"
echo "   Stoppen:  docker-compose down"
echo "   Logs:     docker-compose logs -f"
echo "   Backend:  docker-compose exec backend sh"
echo ""