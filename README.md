# Inventarverwaltung

Webbasierte Inventarverwaltung mit Vue.js Frontend, Laravel Backend und SQLite/MySQL Datenbank.

## 🚀 Schnellstart (Docker)

### Ein-Befehl-Deployment

```bash
docker run -d \
  --name inventarverwaltung \
  -p 3004:80 \
  -e APP_KEY="$(openssl rand -base64 32)" \
  -v inventar_data:/app/data \
  ghcr.io/swissneo85/inventarverwaltung:latest
```

### Mit docker-compose.yml

```yaml
services:
  inventarverwaltung:
    image: ghcr.io/swissneo85/inventarverwaltung:latest
    container_name: inventarverwaltung
    restart: unless-stopped
    ports:
      - "3004:80"
    volumes:
      - ./data:/app/data
    environment:
      - APP_KEY=base64:DEIN_GEHEIMER_KEY_HIER
      - APP_URL=http://localhost:3004
```

```bash
# Starten
docker-compose up -d

# Logs
docker-compose logs -f
```

### Zugriff

- **URL:** http://localhost:3004
- **Benutzer:** admin
- **Passwort:** admin123

⚠️ **Passwort sofort ändern!**

---

## 📦 Image auf GitHub Container Registry

Das fertige Image wird automatisch bei jedem Push auf `main` gebaut:

```
ghcr.io/swissneo85/inventarverwaltung:latest
ghcr.io/swissneo85/inventarverwaltung:v1.0.0
ghcr.io/swissneo85/inventarverwaltung:sha-abc123
```

---

## 🔧 Konfiguration

### Umgebungsvariablen

| Variable | Beschreibung | Standard |
|----------|-------------|----------|
| `APP_KEY` | App-Secret (Base64) | *erforderlich* |
| `APP_URL` | Basis-URL | `http://localhost:3004` |
| `APP_DEBUG` | Debug-Modus | `false` |
| `PORT` | Externer Port | `3004` |

### APP_KEY generieren

```bash
openssl rand -base64 32
# Oder im Container:
docker exec inventarverwaltung php artisan key:generate --show
```

---

## 🌐 Mit MySQL/MariaDB (Optional)

Für größere Installationen:

```yaml
services:
  db:
    image: mariadb:11.2
    environment:
      MYSQL_ROOT_PASSWORD: root_secret
      MYSQL_DATABASE: inventar
      MYSQL_USER: inventar
      MYSQL_PASSWORD: inventar_secret
    volumes:
      - db_data:/var/lib/mysql

  inventarverwaltung:
    image: ghcr.io/swissneo85/inventarverwaltung:latest
    ports:
      - "3004:80"
    environment:
      - APP_KEY=your-key
      - DB_CONNECTION=mysql
      - DB_HOST=db
      - DB_DATABASE=inventar
      - DB_USERNAME=inventar
      - DB_PASSWORD=inventar_secret
    depends_on:
      - db

volumes:
  db_data:
```

---

## 🐛 Problembehandlung

### Container startet nicht

```bash
# Logs prüfen
docker logs inventarverwaltung

# Neu starten
docker restart inventarverwaltung

# Neu bauen
docker pull ghcr.io/swissneo85/inventarverwaltung:latest
docker-compose up -d
```

### APP_KEY Fehler

```bash
# Neuen Key generieren
docker exec inventarverwaltung php artisan key:generate --force
```

### Datenbank resettieren

```bash
# Achtung: Alle Daten gehen verloren!
docker exec inventarverwaltung php artisan migrate:fresh --force
docker exec inventarverwaltung php artisan db:seed --force
```

---

## 📁 Repository

**GitHub:** https://github.com/swissneo85/inventarverwaltung

---

## 📄 Lizenz

MIT