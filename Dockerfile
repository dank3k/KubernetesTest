# Contoh Dockerfile sederhana untuk PHP 8.1 dengan Nginx
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
    nginx

# Bersihkan cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Instal Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Konfigurasi Nginx (contoh sederhana)
COPY nginx.conf /etc/nginx/sites-available/default
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
RUN rm /etc/nginx/sites-available/default

# Salin kode aplikasi
COPY . /var/www/html

# Ganti direktori kerja
WORKDIR /var/www/html

# Instal dependensi Composer
RUN composer install --no-dev --optimize-autoloader

# Beri hak akses ke folder yang dibutuhkan
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Ekspos port
EXPOSE 80
CMD ["php-fpm"]
