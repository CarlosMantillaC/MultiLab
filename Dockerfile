FROM php:8.1-fpm

# Build arguments
ARG UID=1000
ARG GID=1000

# System dependencies
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
    default-mysql-client \
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

# Align www-data with host UID/GID
RUN usermod -u ${UID} www-data \
    && groupmod -g ${GID} www-data

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

RUN mkdir -p /home/www-data && chown -R www-data:www-data /home/www-data /var/www

# Entrypoint
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER www-data

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm", "-F"]
