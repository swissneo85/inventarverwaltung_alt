# ============================================
# Inventarverwaltung - Single-Stage Dockerfile
# ============================================

FROM php:8.4-fpm-alpine

# Install dependencies
RUN apk add --no-cache nginx sqlite sqlite-dev curl supervisor nodejs npm git unzip \
    && docker-php-ext-install pdo_sqlite pdo_mysql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

# Copy backend
COPY backend/ .

# Build frontend
COPY frontend/package.json /tmp/frontend/package.json
RUN cd /tmp/frontend && npm install && mkdir -p /var/www/html/public
COPY frontend/ /tmp/frontend/
RUN cd /tmp/frontend && npm run build && cp -r dist/* /var/www/html/public/

# Install PHP dependencies
RUN composer install --no-dev --ignore-platform-reqs --no-scripts --no-interaction \
    && composer dump-autoload --optimize --no-scripts

# Directories
RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache /app/data /run/php \
    && chown -R www-data:www-data . \
    && chmod -R 775 storage bootstrap/cache

# Create DB
RUN mkdir -p /app/data && touch /app/data/database.sqlite && chmod 666 /app/data/database.sqlite


# Copy configs
COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisor.conf /etc/supervisord.conf
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]
