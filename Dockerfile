# ============================================
# Inventarverwaltung - Production Dockerfile (DB in Image)
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
COPY backend/composer.json ./
RUN composer install --no-dev --ignore-platform-reqs --no-scripts --no-interaction
COPY backend/ ./

# Final Image
FROM php:8.2-fpm-alpine
RUN apk add --no-cache nginx sqlite sqlite-dev curl supervisor
RUN docker-php-ext-install pdo_sqlite pdo_mysql

WORKDIR /var/www/html

COPY --from=backend /app .
COPY --from=frontend /app/dist public

# Laravel Package Discovery
RUN php artisan package:discover --ansi 2>/dev/null || true

# Verzeichnisse + Rechte
RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache /app/data /run/php \
    && chown -R www-data:www-data . \
    && chmod -R 775 storage bootstrap/cache

# Datenbank IM BMAGE erstellen (nicht erst beim Start)
ENV APP_KEY=base64:4n4n4n4n4n4n4n4n4n4n4n4n4n4n4n4n4n4n4=
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV DB_CONNECTION=sqlite
ENV DB_DATABASE=/app/data/database.sqlite
ENV SESSION_DRIVER=file

RUN mkdir -p /app/data \
    && touch /app/data/database.sqlite \
    && chmod 666 /app/data/database.sqlite \
    && chown -R www-data:www-data /app/data \
    && php artisan migrate --force \
    && php artisan db:seed --force \
    && php artisan config:clear || true

COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisor.conf /etc/supervisord.conf
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]
