# Deployment für Hostinger / VPS

## 📦 Schnellstart

### 1. Repository auf Server klonen

```bash
# SSH auf deinen Server
ssh user@your-server

# In Docker-Verzeichnis wechseln
cd /opt  # oder wo du Docker-Apps hast

# Repository klonen
git clone https://github.com/swissneo85/inventarverwaltung.git
cd inventarverwaltung
```

### 2. Konfiguration

```bash
# .env erstellen
cp .env.production .env

# WICHTIG: Passwörter ändern!
nano .env

# Mindestens diese Werte ändern:
# - APP_URL (deine Domain)
# - FRONTEND_URL (deine Domain)  
# - DB_PASSWORD (sicheres Passwort)
# - DB_ROOT_PASSWORD (sicheres Passwort)
# - APP_KEY generieren (siehe unten)
```

### 3. APP_KEY generieren

```bash
# Option A: Mit OpenSSL
openssl rand -base64 32

# Option B: Nach dem ersten Start im Container
docker-compose -f docker-compose.prod.yml exec backend php artisan key:generate
```

### 4. Frontend bauen

```bash
# Node.js installieren falls nicht vorhanden
# Auf Ubuntu/Debian:
apt update && apt install -y nodejs npm

# In Frontend-Verzeichnis
cd frontend
npm install
npm run build

# Zurück
cd ..
```

### 5. Backend-Dependencies installieren

```bash
# Composer installieren falls nicht vorhanden
apt install -y composer

# Im Backend-Verzeichnis
cd backend
composer install --no-dev --optimize-autoloader
cd ..
```

### 6. Container starten

```bash
# Mit docker-compose.prod.yml
docker-compose -f docker-compose.prod.yml up -d

# Datenbank initialisieren
docker-compose -f docker-compose.prod.yml exec db mariadb -u root -p${DB_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS inventar;"
docker-compose -f docker-compose.prod.yml exec backend php artisan migrate --force
docker-compose -f docker-compose.prod.yml exec backend php artisan db:seed --force
```

---

## 🚀 Alternativ: One-Liner Setup

```bash
git clone https://github.com/swissneo85/inventarverwaltung.git \
&& cd inventarverwaltung \
&& cp .env.production .env \
&& nano .env  # Passwörter ändern!
&& cd frontend && npm install && npm run build && cd .. \
&& cd backend && composer install --no-dev && cd .. \
&& docker-compose -f docker-compose.prod.yml up -d \
&& docker-compose -f docker-compose.prod.yml exec backend php artisan key:generate --force \
&& docker-compose -f docker-compose.prod.yml exec backend php artisan migrate --force \
&& docker-compose -f docker-compose.prod.yml exec backend php artisan db:seed --force
```

---

## 🔧 Docker Befehle

```bash
# Container starten
docker-compose -f docker-compose.prod.yml up -d

# Logs anzeigen
docker-compose -f docker-compose.prod.yml logs -f

# Container stoppen
docker-compose -f docker-compose.prod.yml down

# Container neu bauen
docker-compose -f docker-compose.prod.yml build --no-cache

# In Backend-Container
docker-compose -f docker-compose.prod.yml exec backend sh

# In Datenbank-Container
docker-compose -f docker-compose.prod.yml exec db mariadb -u inventar -p
```

---

## 🌐 SSL mit Let's Encrypt (optional)

```bash
# Certbot installieren
apt install -y certbot

# Zertifikat erstellen (Port 80 muss frei sein)
certbot certonly --standalone -d deine-domain.com

# Zertifikate kopieren
cp /etc/letsencrypt/live/deine-domain.com/fullchain.pem nginx/ssl/cert.pem
cp /etc/letsencrypt/live/deine-domain.com/privkey.pem nginx/ssl/key.pem

# Nginx config für HTTPS anpassen
nano nginx/nginx.conf
```

---

## ✅ Nach dem Deployment

1. **Login testen:** `http://deine-domain.com` → admin / admin123
2. **Passwort ändern:** Sofort das Admin-Passwort ändern!
3. **Backup einrichten:** Datenbank regelmäßig sichern

```bash
# Datenbank-Backup
docker-compose -f docker-compose.prod.yml exec db mysqldump -u root -p${DB_ROOT_PASSWORD} inventar > backup_$(date +%Y%m%d).sql
```

---

## 🐛 Probleme?

### Container startet nicht

```bash
# Logs prüfen
docker-compose -f docker-compose.prod.yml logs backend
docker-compose -f docker-compose.prod.yml logs nginx

# Rechte prüfen
chmod -R 775 backend/storage
chmod -R 775 backend/bootstrap/cache
```

### Datenbank-Verbindungsfehler

```bash
# Prüfen ob DB läuft
docker-compose -f docker-compose.prod.yml ps

# DB neustarten
docker-compose -f docker-compose.prod.yml restart db
```

### Frontend zeigt nichts

```bash
# Prüfen ob dist existiert
ls -la frontend/dist/

# Neu bauen
cd frontend && npm run build && cd ..
```