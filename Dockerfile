# Use the base PHP-FPM image
FROM php:8.2-fpm-alpine

# Set the working directory inside the container
WORKDIR /var/www/html

# Install system dependencies and required PHP extensions
# The order is important: install system libraries first, then PHP extensions.
RUN apk update && apk add --no-cache \
    git \
    libzip-dev \
    libpng-dev \
    jpeg-dev \
    libjpeg-turbo-dev \
    oniguruma-dev \
    icu-dev \
    curl-dev \
    bash \
    tzdata \
    libxml2-dev \
    mariadb-connector-c-dev \
    && rm -rf /var/cache/apk/*

# Install the necessary PHP extensions
RUN docker-php-ext-install -j$(nproc) \
    pdo \
    pdo_mysql \
    opcache \
    intl \
    mbstring \
    iconv \
    curl
RUN docker-php-ext-configure gd --with-jpeg && docker-php-ext-install -j$(nproc) gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Copy ALL project files into the container
COPY . /var/www/html

# Install PHP dependencies with Composer
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Change file ownership to be accessible by Nginx and PHP-FPM
RUN chown -R www-data:www-data /var/www/html

# Make sure Laravel cache folders are writable
RUN chmod -R 775 /var/www/html/storage
RUN chmod -R 775 /var/www/html/bootstrap/cache

# Run PHP-FPM
CMD ["php-fpm"]
