# ============================================
# Inventarverwaltung - Single-Stage Dockerfile
# ============================================

FROM php:8.2-fpm-alpine

# Alles installieren
RUN apk add --no-cache nginx sqlite sqlite-dev curl supervisor nodejs npm git unzip \
    && docker-php-ext-install pdo_sqlite pdo_mysql

# Composer installieren
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

# Backend kopieren
COPY backend/ .

# Frontend bauen
COPY frontend/package.json /tmp/frontend/package.json
RUN cd /tmp/frontend && npm install && mkdir -p /var/www/html/public
COPY frontend/ /tmp/frontend/
RUN cd /tmp/frontend && npm run build && cp -r dist/* /var/www/html/public/

# Dependencies installieren
RUN composer install --no-dev --ignore-platform-reqs --no-scripts --no-interaction \
    && composer dump-autoload --optimize --no-scripts

# Laravel optimieren
RUN php artisan package:discover --ansi \
    && php artisan optimize \
    && artisan config:clear

# Verzeichnisse
RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache /app/data /run/php \
    && chown -R www-data:www-data . \
    && chmod -R 775 storage bootstrap/cache

# Datenbank erstellen
RUN mkdir -p /app/data && touch /app/data/database.sqlite && chmod 666 /app/data/database.sqlite \
    && php artisan migrate --force \
    && php artisan db:seed --force

# Configs
COPY to docker/nginx.conf /etc/nginx/http.d/default.conf
COPY to docker/supervisor.conf /etc/supervisord.conf
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]
