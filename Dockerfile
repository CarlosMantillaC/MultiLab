FROM php:8.1-fpm AS base

ARG UID=1000
ARG GID=1000

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    zip \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) \
      pdo_mysql \
      mbstring \
      exif \
      pcntl \
      bcmath \
      gd \
      intl \
      zip \
  && rm -rf /var/lib/apt/lists/*

RUN usermod -u ${UID} www-data && groupmod -g ${GID} www-data \
    && mkdir -p /home/www-data && chown -R www-data:www-data /home/www-data

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

FROM base AS dev

RUN apt-get update && apt-get install -y nodejs npm \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install xdebug && docker-php-ext-enable xdebug

USER www-data

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm", "-F"]

FROM base AS prod

COPY --chown=www-data:www-data . .

RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --no-progress

RUN apt-get update && apt-get install -y nodejs npm \
    && npm install \
    && npm run build \
    && rm -rf node_modules \
    && apt-get purge -y nodejs npm \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage \
    && chmod -R 755 /var/www/public

USER www-data

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm", "-F"]
