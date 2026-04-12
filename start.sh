#!/bin/bash

# Starten der Inventarverwaltung mit Docker
# ==========================================

echo "🚀 Starte Inventarverwaltung..."

# Prüfen ob Docker läuft
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker läuft nicht. Bitte Docker starten."
    exit 1
fi

# .env erstellen falls nicht vorhanden
if [ ! -f ".env" ]; then
    echo "📝 Erstelle .env Datei..."
    cp .env.example .env
fi

# Backend .env erstellen falls nicht vorhanden
if [ ! -f "backend/.env" ]; then
    echo "📝 Erstelle backend/.env Datei..."
    cp backend/.env.example backend/.env
fi

# Container bauen und starten
echo "🐳 Baue und starte Container..."
docker-compose build
docker-compose up -d

# Warten bis Container bereit sind
echo "⏳ Warte auf Container..."
sleep 10

# Laravel initialisieren
echo "⚙️  Initialisiere Laravel..."
docker-compose exec -T backend ash -c '
    until nc -z db 3306; do
        echo "Warte auf Datenbank..."
        sleep 2
    done
    
    echo "Datenbank bereit!"
    
    if [ -z "$APP_KEY" ]; then
        php artisan key:generate --force
    fi
    
    php artisan migrate --force
    php artisan db:seed --force
'

echo ""
echo "✅ Inventarverwaltung ist bereit!"
echo ""
echo "🌐 Zugriff:"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:8080"
echo ""
echo "🔑 Login-Daten:"
echo "   Admin: admin / admin123"
echo "   User:  max / password"
echo ""
echo "🛑 Stoppen: docker-compose down"
echo "📊 Logs:    docker-compose logs -f"
echo ""