# ============================================
# Inventarverwaltung - Production Dockerfile
# Ähnlich aufgebaut wie kosten-tracker
# ============================================

# Stage 1: Build Frontend
FROM node:22-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Stage 2: Production Image
FROM php:8.2-fpm-alpine

# Install nginx + dependencies
RUN apk add --no-cache \
    nginx \
    sqlite \
    sqlite-dev \
    curl \
    && docker-php-ext-install pdo_sqlite pdo_mysql session

WORKDIR /var/www/html

# Copy backend (Laravel)
COPY backend/ .

# Copy frontend build to public
COPY --from=frontend-builder /app/frontend/dist ./public

# Create directories
RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache /app/data /run/php \
    && chown -R www-data:www-data . \
    && chmod -R 775 storage bootstrap/cache

# Nginx config
COPY docker/nginx-simple.conf /etc/nginx/http.d/default.conf

# Supervisor
COPY docker/supervisord-simple.conf /etc/supervisord.conf

# Init script
COPY docker/init-simple.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost/api/health || exit 1

CMD ["/init.sh"]