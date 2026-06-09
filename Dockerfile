# ============================================
# Inventarverwaltung - Production Dockerfile (FIXED v10)
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
# Composer Security Advisories blocking ausschalten
RUN mkdir -p /root/.composer \
    && echo '{"config":{"policy":{"advisories":{"block":false}}}}' > /root/.composer/config.json \
    && composer update --no-dev --ignore-platform-reqs --no-scripts --no-interaction --no-audit
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

RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache /app/data /run/php \
    && chown -R www-data:www-data . \
    && chmod -R 775 storage bootstrap/cache

COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisor.conf /etc/supervisord.conf
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]
