# Menggunakan image dasar PHP-FPM
FROM php:8.2-fpm-alpine

# Mengatur working directory di dalam container
WORKDIR /var/www/html

# Menginstal dependensi sistem dan ekstensi PHP yang dibutuhkan
RUN apk update && apk add --no-cache \
    git \
    libzip-dev \
    libpng-dev \
    jpeg-dev \
    oniguruma-dev \
    bash \
    tzdata \
    icu-dev \
    && rm -rf /var/cache/apk/*

# Menginstal ekstensi PHP yang diperlukan
# Ekstensi 'intl' ditambahkan untuk memenuhi persyaratan Aimeos
RUN docker-php-ext-install pdo pdo_mysql opcache intl
RUN docker-php-ext-configure gd --with-jpeg && docker-php-ext-install gd

# Menginstal Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Salin file composer.json dan composer.lock untuk caching yang lebih baik
COPY composer.json composer.lock ./

# Menginstal dependensi PHP menggunakan Composer
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Salin semua file dari direktori lokal ke direktori kerja container
COPY . /var/www/html

# Mengubah kepemilikan file agar dapat diakses oleh Nginx dan PHP-FPM
# Ini adalah langkah KRUSIAL untuk mengatasi error 403 Forbidden
RUN chown -R www-data:www-data /var/www/html

# Memastikan folder cache Laravel dapat ditulis
RUN chmod -R 775 /var/www/html/storage
RUN chmod -R 775 /var/www/html/bootstrap/cache

# Menjalankan PHP-FPM
CMD ["php-fpm"]
