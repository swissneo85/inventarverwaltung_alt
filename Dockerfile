# ============================================
# All-in-One Production Dockerfile
# Ein einziger Container für alles
# ============================================

# Stage 1: Build Backend Dependencies
FROM composer:2 AS backend-builder

WORKDIR /backend
COPY backend/composer.json backend/composer.lock* ./
RUN composer install --no-dev --no-scripts --no-autoloader --no-interaction || \
    composer install --no-dev --no-scripts --no-autoloader --no-interaction --ignore-platform-reqs
COPY backend/ .
RUN composer dump-autoload --no-dev --optimize --no-interaction

# Stage 2: Build Frontend
FROM node:22-alpine AS frontend-builder

WORKDIR /frontend

# Copy package files
COPY frontend/package*.json ./

# Install ALL dependencies (including devDependencies for build)
RUN npm ci

# Copy source and build
COPY frontend/ .
RUN npm run build

# Stage 3: Production Image
FROM php:8.2-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    curl \
    sqlite \
    sqlite-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    icu-dev \
    oniguruma-dev \
    libxml2-dev \
    && docker-php-ext-install \
    pdo_mysql \
    pdo_sqlite \
    mysqli \
    zip \
    intl \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    xml

# Create directories
WORKDIR /var/www/html
RUN mkdir -p \
    /var/www/html/storage/logs \
    /var/www/html/storage/framework/cache \
    /var/www/html/storage/framework/sessions \
    /var/www/html/storage/framework/views \
    /var/www/html/bootstrap/cache \
    /var/www/html/public \
    /app/data \
    /run/php

# Copy backend application
COPY --from=backend-builder /backend /var/www/html

# Copy frontend build to public directory
COPY --from=frontend-builder /frontend/dist /var/www/html/public

# Copy nginx configuration
COPY docker/nginx-all-in-one.conf /etc/nginx/http.d/default.conf

# Copy supervisor configuration
COPY docker/supervisord-all-in-one.conf /etc/supervisor/conf.d/supervisord.conf

# Copy initialization script
COPY docker/init-container.sh /init-container.sh
RUN chmod +x /init-container.sh

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache \
    && chmod -R 775 /app/data \
    && chown -R www-data:www-data /app/data

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost/api/health || exit 1

# Start services
CMD ["/init-container.sh"]