# ============================================
# Inventarverwaltung - Root-User Dockerfile
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

# Fix ALL permissions - make everything writable by root (which runs php-fpm)
RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache /app/data /run/php \
    && chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public /var/www/html/resources

# Create DB
RUN mkdir -p /app/data && touch /app/data/database.sqlite && chmod 777 /app/data/database.sqlite

# PHP-FPM as root (radical fix for permissions)
RUN sed -i 's/^user = .*/user = root/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/^group = .*/group = root/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/^;listen.owner/listen.owner/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/^;listen.group/listen.group/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/^listen.owner = .*/listen.owner = root/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/^listen.group = .*/listen.group = root/' /usr/local/etc/php-fpm.d/www.conf

# Copy configs
COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisor.conf /etc/supervisord.conf
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]
