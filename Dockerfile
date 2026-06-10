# ============================================
# Inventarverwaltung - Slim Single-Stage Dockerfile
# ============================================
# Optimiert für Hostinger VPS mit wenig RAM
# Bauen mit: docker build -t inventarverwaltung:hostinger .

FROM php:8.4-cli-alpine AS composer-build
RUN apk add --no-cache curl
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

FROM node:22-alpine AS node-build
COPY frontend/package*.json /app/
WORKDIR /app
RUN npm ci
COPY frontend/ /app/
RUN npm run build

FROM php:8.4-fpm-alpine
LABEL maintainer="swissneo85"

RUN apk add --no-cache nginx supervisor sqlite sqlite-dev \
    && docker-php-ext-install pdo_sqlite pdo_mysql \
    && mkdir -p /run/php /var/log/supervisor /app/data \
    && rm -rf /var/cache/apk/*

WORKDIR /var/www/html

# Copy Composer binary
COPY --from=composer-build /usr/local/bin/composer /usr/local/bin/composer

# Copy backend code
COPY backend/composer.json backend/composer.lock* ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs \
    && composer dump-autoload --optimize --no-interaction
COPY backend/ .

# Copy pre-built frontend → public
COPY --from=node-build /app/dist ./public

# Ensure storage dirs exist and are writable
RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions \
    storage/framework/views bootstrap/cache /app/data \
    && chmod -R 777 storage bootstrap/cache /app/data

# Nginx + Supervisor configs
COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisor.conf /etc/supervisord.conf

# Startup script
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80
STOPSIGNAL SIGTERM
CMD ["/start.sh"]
