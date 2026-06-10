# Inventarverwaltung (Hostinger Edition)

Webbasierte Inventarverwaltung mit Vue.js Frontend und Laravel Backend.  
**Optimiert für Hostinger VPS (wenig RAM/CPU).**

---

## 🚨 WICHTIG: Bekannte Probleme & Fixes

| Problem | Ursache | Fix |
|---------|---------|-----|
| Hostinger stürzt ab / hängt 30min | `php artisan optimize` beim Start frisst zu viel RAM | Start-Skript überarbeitet — kein optimize mehr |
| Login `admin` / `admin123` funktioniert nicht | `APP_KEY` war nicht gesetzt → Sanctum Token konnte nicht erstellt werden | APP_KEY wird jetzt automatisch generiert |
| Image zu groß für VPS | Altes Dockerfile baute alles in einem Schritt | Multi-Stage Build — Image ~50% kleiner |

---

## 🚀 Schnellstart für Hostinger VPS

### 1. Verbinde dich per SSH mit deinem Hostinger-Server

### 2. Erstelle einen Ordner und wechsle hinein

```bash
mkdir inventarverwaltung && cd inventarverwaltung
```

### 3. Lade das Setup-Skript herunter

```bash
curl -sL https://raw.githubusercontent.com/swissneo85/inventarverwaltung_alt/main/hostinger-setup.sh -o setup.sh
chmod +x setup.sh
```

Oder **manuell** (schneller):

```bash
# .env mit APP_KEY erstellen
echo "APP_KEY=base64:$(openssl rand -base64 32)" > .env
echo "APP_URL=http://localhost:3004" >> .env

# Docker Compose Datei
curl -sL https://raw.githubusercontent.com/swissneo85/inventarverwaltung_alt/main/docker-compose.hostinger.yml -o docker-compose.yml

# Ordner für Daten anlegen
mkdir -p data storage

# Container starten
docker compose up -d
```

### 4. Zugriff

- **URL:** `http://DEINE-SERVER-IP:3004`
- **Login:** `admin` / `admin123`

> ⚠️ **Sofort das Passwort ändern nach dem ersten Login!**

---

## 🔄 Update

```bash
cd inventarverwaltung
docker compose pull
docker compose up -d
```

---

## 🐳 Docker Image

```
ghcr.io/swissneo85/inventarverwaltung_alt:hostinger
```

---

## 🔧 Umgebungsvariablen

| Variable | Standard | Beschreibung |
|----------|----------|--------------|
| `APP_KEY` | *automatisch* | Laravel App-Key (base64) |
| `APP_URL` | `http://localhost:3004` | Deine Server-URL |
| `PORT` | `3004` | Externer Port |
| `DB_CONNECTION` | `sqlite` | SQLite (kein MySQL nötig) |
| `SESSION_DRIVER` | `file` | Session-Dateien statt DB |

---

## 📄 Lizenz

MIT
