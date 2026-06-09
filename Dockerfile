# ============================================
# Inventarverwaltung - Production Dockerfile (FIXED v4)
# ============================================

# Frontend bauen
FROM node:22-alpine AS frontend
WORKDIR /app
COPY frontend/package.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# Backend bauen  
FROM php:8.2-cli AS backend
WORKDIR /app

# Installiere Composer + PHP Extensions für Laravel
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev libsqlite3-dev \
    && docker-php-ext-install pdo pdo_mysql pdo_sqlite \
    dom xml mbstring curl zip bcmath fileinfo opcache gd \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY backend/composer.json ./
# composer update weil composer.lock fehlt/inkomplett war
RUN composer update --no-dev --optimize-autoloader --ignore-platform-reqs --no-scripts --no-interaction
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
