# Gunakan image PHP-FPM resmi
FROM php:8.1-fpm

# Instal dependensi sistem dan ekstensi PHP
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
    nginx

# Instal ekstensi PHP yang dibutuhkan (untuk Laravel/Aimeos)
RUN docker-php-ext-install pdo_mysql exif pcntl gd dom intl zip

# Hapus cache APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Instal Composer secara global
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Atur direktori kerja ke dalam container
WORKDIR /var/www/html

# Salin semua file dari direktori lokal ke direktori kerja container
COPY . /var/www/html

# Tambahkan Git trust untuk direktori
RUN git config --global --add safe.directory /var/www/html

# Instal dependensi Composer
RUN composer install --no-dev --optimize-autoloader

# Beri hak akses ke folder yang dibutuhkan oleh Laravel/Aimeos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Ekspos port default PHP-FPM
EXPOSE 9000

# Perintah default untuk menjalankan PHP-FPM
CMD ["php-fpm"]
