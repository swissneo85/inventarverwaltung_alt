# ============================================
# Inventarverwaltung - Production Dockerfile
# ============================================
# Baut alles in einem Stage (funktioniert zuverlässig)
# Kein Multi-Stage — vermeidet Build-Probleme

FROM php:8.4-fpm-alpine

# Install dependencies
RUN apk add --no-cache nginx sqlite sqlite-dev curl supervisor nodejs npm git unzip \
    && docker-php-ext-install pdo_sqlite pdo_mysql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

# Copy backend
COPY backend/ .

# Create .env file directly (not from gitignored file)
RUN cat > /var/www/html/.env <<'EOF'
APP_NAME=Inventarverwaltung
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://localhost:3004
FRONTEND_URL=http://localhost:3004
DB_CONNECTION=sqlite
DB_DATABASE=/app/data/database.sqlite
SESSION_DRIVER=file
SESSION_LIFETIME=120
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
LOG_CHANNEL=errorlog
LOG_LEVEL=warning
EOF

# Build frontend
COPY frontend/package.json /tmp/frontend/package.json
RUN cd /tmp/frontend && npm install && mkdir -p /var/www/html/public
COPY frontend/ /tmp/frontend/
RUN cd /tmp/frontend && npm run build && cp -r dist/* /var/www/html/public/

# Install PHP dependencies (--no-scripts verhindert Post-Install Fehler)
RUN composer install --no-dev --ignore-platform-reqs --no-scripts --no-interaction \
    && composer dump-autoload --optimize --no-scripts

# Permissions
RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache /app/data /run/php \
    && chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache /app/data

# Create DB
RUN touch /app/data/database.sqlite && chmod 666 /app/data/database.sqlite

# Copy configs
COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisor.conf /etc/supervisord.conf
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]
