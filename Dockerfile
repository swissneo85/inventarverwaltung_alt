# ============================================
# Inventarverwaltung - Production Dockerfile (FIXED v2)
# ============================================

# Frontend bauen
FROM node:22-alpine AS frontend
WORKDIR /app
COPY frontend/package.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# Backend bauen  
FROM composer:2 AS backend
WORKDIR /app
COPY backend/composer.json backend/composer.lock ./
# --no-scripts: verhindert dass artisan package:discover läuft
# bevor die App-Dateien kopiert sind
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs --no-scripts
COPY backend/ ./

# Final Image
FROM php:8.2-fpm-alpine
RUN apk add --no-cache nginx sqlite sqlite-dev curl supervisor
RUN docker-php-ext-install pdo_sqlite pdo_mysql

WORKDIR /var/www/html

COPY --from=backend /app .
COPY --from=frontend /app/dist public

# Laravel Package Discovery + Caching
RUN php artisan package:discover --ansi 2>/dev/null || true
RUN php artisan config:cache 2>/dev/null || true
RUN php artisan route:cache 2>/dev/null || true

RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache /app/data /run/php \
    && chown -R www-data:www-data . \
    && chmod -R 775 storage bootstrap/cache

COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisor.conf /etc/supervisord.conf
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]
