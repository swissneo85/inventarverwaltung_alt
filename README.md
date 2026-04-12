# Inventarverwaltung

Webbasierte Inventarverwaltung mit Vue.js Frontend, Laravel Backend und MariaDB Datenbank.

## Features

- **Räume, Boxen und Items verwalten** mit sichtbaren Kennungen (R1, B1, I1)
- **QR-Code Unterstützung** für schnelles Scannen und Finden
- **Inbox** für nicht zugeordnete Gegenstände
- **Kategorien und Rechteverwaltung** für Benutzerzugriff
- **Responsive Design** für Desktop und Mobile
- **Listen- und Tabellenansicht** für flexible Darstellung
- **Suche** nach Name, ID, Beschreibung, Seriennummer etc.
- **Garantie-Tracking** mit Warnungen bei Ablauf
- **Login-Protokoll** für Sicherheit

## Tech Stack

- **Frontend**: Vue.js 3 + Vite + TypeScript
- **Backend**: Laravel 11 (PHP 8.2+)
- **Datenbank**: MariaDB / MySQL
- **Auth**: Laravel Sanctum (Token-basiert)
- **Container**: Docker + Docker Compose

## Quick Start

```bash
# Repository klonen
git clone https://github.com/swissneo85/inventarverwaltung.git
cd inventarverwaltung

# Umgebungsvariablen kopieren
cp .env.example .env

# Backend .env erstellen
cp backend/.env.example backend/.env

# Mit Docker starten
docker-compose up -d

# Datenbank initialisieren
docker-compose exec backend php artisan migrate --seed

# Frontend bauen
docker-compose exec frontend npm run build
```

## Standard-Zugangsdaten

Nach dem Seed:
- **Admin**: admin / admin123
- **Benutzer**: max / password

## Entwicklung

### Backend (Laravel)

```bash
cd backend

# Abhängigkeiten installieren
composer install

# Migration ausführen
php artisan migrate

# Seed (Beispieldaten)
php artisan db:seed

# Entwicklungsserver
php artisan serve
```

### Frontend (Vue.js)

```bash
cd frontend

# Abhängigkeiten installieren
npm install

# Entwicklungsserver
npm run dev

# Production Build
npm run build
```

## API Endpunkte

### Auth
- `POST /api/login` - Login
- `POST /api/logout` - Logout
- `GET /api/me` - Aktueller Benutzer

### Items
- `GET /api/items` - Alle Items
- `POST /api/items` - Item erstellen
- `GET /api/items/{id}` - Item anzeigen
- `PUT /api/items/{id}` - Item bearbeiten
- `DELETE /api/items/{id}` - Item löschen
- `POST /api/items/{id}/assign-room` - Raum zuweisen
- `POST /api/items/{id}/assign-box` - Box zuweisen
- `POST /api/items/{id}/move-to-inbox` - Zur Inbox
- `POST /api/items/{id}/qr-code` - QR-Code generieren

### Boxen & Räume
- `GET /api/boxes` - Alle Boxen
- `GET /api/rooms` - Alle Räume
- usw.

### Suche
- `GET /api/search?q=...` - Globale Suche
- `GET /api/search/quick?q=...` - Schnellsuche

### Dashboard
- `GET /api/dashboard/stats` - Statistiken
- `GET /api/dashboard/inbox` - Inbox-Übersicht

## Struktur

```
inventarverwaltung/
├── backend/              # Laravel API
│   ├── app/
│   │   ├── Http/
│   │   │   └── Controllers/Api/
│   │   └── Models/
│   ├── database/
│   │   ├── migrations/
│   │   └── seeders/
│   └── routes/
│       └── api.php
├── frontend/            # Vue.js SPA
│   ├── src/
│   │   ├── components/
│   │   ├── views/
│   │   ├── stores/
│   │   ├── services/
│   │   └── router/
│   └── package.json
├── docker-compose.yml
└── README.md
```

## Lizenz

MIT