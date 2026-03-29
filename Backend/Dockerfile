FROM dunglas/frankenphp:php8.3

RUN apt-get update && apt-get install -y \
    ffmpeg \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    libzip-dev \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libonig-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# install redis extension
RUN pecl install redis && docker-php-ext-enable redis

WORKDIR /app

COPY . /app

# COPY php.ini /usr/local/etc/php/php.ini

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

CMD ["php","artisan","octane:start","--server=frankenphp","--workers=8","--max-requests=1000","--host=0.0.0.0","--port=8000"]