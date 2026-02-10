FROM php:8.1-fpm

# ----------------------------
# Build arguments (ANTES)
# ----------------------------
ARG UID=1000
ARG GID=1000

# ----------------------------
# System dependencies
# ----------------------------
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

# ----------------------------
# Align www-data with host UID/GID
# ----------------------------
RUN usermod -u ${UID} www-data \
 && groupmod -g ${GID} www-data

# ----------------------------
# Composer
# ----------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ----------------------------
# Workdir
# ----------------------------
WORKDIR /var/www

# ----------------------------
# Entrypoint
# ----------------------------
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm", "-F"]
