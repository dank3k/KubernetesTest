# Gunakan image PHP-FPM resmi
FROM php:8.1-fpm

# Instal dependensi sistem dan ekstensi PHP yang dibutuhkan oleh Laravel dan Aimeos
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libicu-dev \
    libzip-dev \
    nginx \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instal ekstensi PHP yang dibutuhkan (untuk Laravel/Aimeos)
RUN docker-php-ext-install pdo_mysql exif pcntl gd dom intl zip

# Instal Composer secara global
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Atur direktori kerja ke dalam container
WORKDIR /var/www/html

# Salin semua file dari direktori lokal ke direktori kerja container
COPY . /var/www/html

# Ubah kepemilikan file agar dapat diakses oleh Nginx dan PHP-FPM
RUN chown -R www-data:www-data /var/www/html

# Tambahkan Git trust untuk direktori
RUN git config --global --add safe.directory /var/www/html

# Instal dependensi Composer
RUN composer install --no-dev --optimize-autoloader

# Buat direktori yang dibutuhkan dan berikan izin
RUN mkdir -p /var/www/html/storage/framework/cache \
           /var/www/html/storage/framework/sessions \
           /var/www/html/storage/framework/views \
           /var/www/html/storage/logs \
           /var/www/html/bootstrap/cache && \
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Ekspos port default PHP-FPM
EXPOSE 9000

# Perintah default untuk menjalankan PHP-FPM
CMD ["php-fpm"]
