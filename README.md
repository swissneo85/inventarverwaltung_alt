# Inventarverwaltung

Webbasierte Inventarverwaltung mit Vue.js Frontend und Laravel Backend.

## 🚀 Deployment (wie Kosten-Tracker)

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
      - APP_KEY=base64:DEIN_GEHEIMER_KEY
```

```bash
# APP_KEY generieren
openssl rand -base64 32

# Starten
docker-compose up -d
```

## 🔑 Login

- **URL:** http://localhost:3004
- **Benutzer:** admin
- **Passwort:** admin123

⚠️ Passwort sofort ändern!

---

## 📦 Image

```
ghcr.io/swissneo85/inventarverwaltung:latest
```

---

## 🔧 Umgebungsvariablen

| Variable | Beschreibung |
|----------|-------------|
| `APP_KEY` | App-Secret (Base64) |
| `APP_URL` | Basis-URL |

---

## 📄 Lizenz

MIT