# Inventarverwaltung

Webbasierte Inventarverwaltung mit Vue.js Frontend, Laravel Backend und MariaDB Datenbank.

## 🚀 Quick Start

### Mit Docker (Empfohlen)

```bash
# Repository klonen
git clone https://github.com/swissneo85/inventarverwaltung.git
cd inventarverwaltung

# Start-Script ausführen
chmod +x start.sh
./start.sh
```

### Manuell

```bash
# 1. .env erstellen
cp .env.example .env
cp backend/.env.example backend/.env

# 2. Container starten
docker-compose up -d

# 3. Datenbank initialisieren (warten bis DB bereit ist)
docker-compose exec backend php artisan key:generate
docker-compose exec backend php artisan migrate
docker-compose exec backend php artisan db:seed

# 4. Frontend für Entwicklung starten (optional)
docker-compose --profile dev up frontend-dev
```

## 🌐 Zugriff

- **Frontend (Dev):** http://localhost:3000
- **Backend API:** http://localhost:8080/api
- **Datenbank:** localhost:3306

## 🔑 Standard-Login

| Rolle | Benutzer | Passwort |
|-------|---------|----------|
| Admin | admin | admin123 |
| User | max | password |

## 📦 Docker Services

| Service | Port | Beschreibung |
|---------|------|-------------|
| `db` | 3306 | MariaDB 11.2 |
| `backend` | 8080 | Laravel API (PHP 8.2 + Nginx) |
| `frontend-dev` | 3000 | Vue.js Dev Server (Hot Reload) |

## 🛠️ Entwicklung

### Backend (Laravel)

```bash
# In Container einloggen
docker-compose exec backend sh

# Artisan Commands
php artisan migrate
php artisan db:seed
php artisan tinker

# Neue Migration erstellen
php artisan make:migration create_xxx_table
```

### Frontend (Vue.js)

```bash
# Dependencies installieren
cd frontend
npm install

# Dev Server
npm run dev

# Production Build
npm run build
```

## 📁 Projektstruktur

```
inventarverwaltung/
├── backend/                 # Laravel 11 API
│   ├── app/
│   │   ├── Http/
│   │   │   └── Controllers/Api/
│   │   ├── Models/
│   │   └── Http/Middleware/
│   ├── database/
│   │   ├── migrations/
│   │   └── seeders/
│   ├── routes/
│   │   └── api.php
│   └── Dockerfile
├── frontend/                # Vue.js 3 SPA
│   ├── src/
│   │   ├── components/
│   │   ├── views/
│   │   ├── stores/
│   │   ├── services/
│   │   └── router/
│   └── Dockerfile
├── docker-compose.yml
├── start.sh
└── README.md
```

## ✨ Features

- **Räume, Boxen & Items** mit sichtbaren IDs (R1, B1, I1)
- **QR-Code** Unterstützung für schnelles Scannen
- **Inbox** für nicht zugeordnete Gegenstände
- **Kategorien & Rechteverwaltung**
- **Responsive Design** (Desktop + Mobile)
- **Listen- & Tabellenansicht**
- **Globale Suche** mit Display-ID
- **Garantie-Tracking**
- **Login-Protokoll** für Sicherheit

## 🔧 API Endpunkte

| Methode | Endpoint | Beschreibung |
|---------|----------|--------------|
| POST | `/api/login` | Login |
| POST | `/api/logout` | Logout |
| GET | `/api/me` | Aktueller Benutzer |
| GET | `/api/items` | Alle Items |
| POST | `/api/items` | Item erstellen |
| GET | `/api/items/{id}` | Item anzeigen |
| PUT | `/api/items/{id}` | Item bearbeiten |
| DELETE | `/api/items/{id}` | Item löschen |
| POST | `/api/scan` | QR-Code scannen |
| GET | `/api/dashboard/stats` | Statistiken |

## 📝 Konfiguration

### Umgebungsvariablen (.env)

```env
# App
APP_NAME=Inventarverwaltung
APP_URL=http://localhost:8080
FRONTEND_URL=http://localhost:3000

# Database
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=inventar
DB_USERNAME=inventar
DB_PASSWORD=inventar_secret
```

## 🛑 Stoppen

```bash
# Container stoppen
docker-compose down

# Mit Volume löschung
docker-compose down -v
```

## 📄 Lizenz

MIT