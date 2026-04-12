# Inventarverwaltung - Production Deployment

## 📦 Schnelles Deployment auf Hostinger VPS

### Ein-Befehl-Installation

```bash
# SSH auf deinen Server
ssh user@your-server

# Herunterladen und installieren
git clone https://github.com/swissneo85/inventarverwaltung.git \
&& cd inventarverwaltung \
&& chmod +x deploy.sh \
&& ./deploy.sh
```

Das war's! Das Script macht alles automatisch:
- ✅ Docker prüfen
- ✅ Passwörter generieren
- ✅ Frontend bauen
- ✅ Backend Dependencies installieren
- ✅ Container starten
- ✅ Datenbank initialisieren
- ✅ Admin-User erstellen

---

## 🌐 Nach der Installation

| URL | Beschreibung |
|-----|-------------|
| `http://deine-ip` | Inventarverwaltung |
| Port 80 | HTTP (Standard) |
| Port 443 | HTTPS (nach SSL Setup) |

### Standard-Login

| Benutzer | Passwort |
|---------|---------|
| admin | admin123 |

⚠️ **Sofort ändern!**

---

## 🔧 Manuelle Befehle

```bash
# Container stoppen
docker-compose -f docker-compose.prod.yml down

# Container starten
docker-compose -f docker-compose.prod.yml up -d

# Logs anzeigen
docker-compose -f docker-compose.prod.yml logs -f

# Neu bauen
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
```

---

## 🔒 SSL einrichten (optional)

```bash
# Certbot installieren
apt install -y certbot

# Zertifikat holen (Port 80 muss frei sein)
certbot certonly --standalone -d deine-domain.com
```

---

## 📁 Dateien

| Datei | Beschreibung |
|------|-------------|
| `docker-compose.prod.yml` | Production Docker Config |
| `deploy.sh` | Auto-Install Script |
| `DEPLOY.md` | Detaillierte Anleitung |
| `.env.production` | Vorlage für Umgebungsvariablen |

---

## 🐛 Problembehandlung

### Container startet nicht

```bash
# Logs prüfen
docker-compose -f docker-compose.prod.yml logs

# Neu bauen
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
```

### Datenbank-Verbindungsfehler

```bash
# DB neu starten
docker-compose -f docker-compose.prod.yml restart db
docker-compose -f docker-compose.prod.yml restart backend
```

### White Screen

```bash
# Rechte setzen
chmod -R 775 backend/storage
chmod -R 775 backend/bootstrap/cache

# Cache leeren
docker exec inventar-backend php artisan cache:clear
```

---

**Repository:** https://github.com/swissneo85/inventarverwaltung