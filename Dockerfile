# ============================================
# Inventarverwaltung - Production Dockerfile
# ===========================================

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
COPY backend/composer.json ./
RUN composer update --no-dev --optimize-autoloader --ignore-platform-reqs --no-scripts --no-interaction
COPY backend/ ./
# Autoloader ohne Scripts
RUN composer dump-autoload --optimize --no-scripts

# Final Image
FROM php:8.2-fpm-alpine
RUN apk add --no-cache nginx sqlite sqlite-dev curl supervisor
RUN docker-php-ext-install pdo_sqlite pdo_mysql

WORKDIR /var/www/html

COPY --from=backend /app .
COPY --from=frontend /app/dist public

# Laravel optimize
RUN php artisan package:discover --ansi 2>/dev/null || true
RUN php artisan optimize 2>/dev/null || true

RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache /app/data /run/php \
    && chown -R www-data:www-data . \
    && chmod -R 775 storage bootstrap/cache

# Setup DE in image
RUN mkdir -p /app/data && touch /app/data/database.sqlite && chmod 666 /app/data/database.sqlite
RUN php artisan migrate --force 2>&1 || true
RUN php artisan db:seed --force 2>&1 || true

COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisor.conf /etc/supervisord.conf
COPY to docker/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]
