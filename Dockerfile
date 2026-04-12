# ============================================
# Inventarverwaltung - Single Stage Build
# Einfach wie kosten-tracker
# ============================================

# Frontend bauen
FROM node:22-alpine AS frontend
WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Backend bauen
FROM composer:2 AS backend
WORKDIR /app
COPY backend/composer.json ./
RUN composer install --no-dev --ignore-platform-reqs
COPY backend/ ./

# Final Image
FROM php:8.2-fpm-alpine
RUN apk add --no-cache nginx sqlite sqlite-dev curl
RUN docker-php-ext-install pdo_sqlite pdo_mysql

WORKDIR /var/www/html

# Backend kopieren
COPY --from=backend /app .

# Frontend build kopieren  
COPY --from=frontend /app/dist public

# Setup
RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache /app/data /run/php \
    && chown -R www-data:www-data . \
    && chmod -R 775 storage bootstrap/cache

# Configs
COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisor.conf /etc/supervisord.conf
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]