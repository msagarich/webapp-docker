FROM php:8.2-apache

# Document root を public に変更
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Apache 設定の修正と必要な PHP 拡張のインストール
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    zip \
 && docker-php-ext-install pdo pdo_mysql zip \
 && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
 && sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf