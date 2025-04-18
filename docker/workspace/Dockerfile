FROM php:8.2-cli

# 開発用ツールや composer をインストール
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    zip \
    curl \
    default-mysql-client \
    default-libmysqlclient-dev \
    libonig-dev \
    nodejs \
    npm \
 && docker-php-ext-install pdo pdo_mysql zip \
 && docker-php-ext-enable pdo_mysql

# Composer install
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer