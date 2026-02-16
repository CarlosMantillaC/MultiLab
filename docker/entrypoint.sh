#!/bin/sh
set -e

if [ "$APP_ENV" = "production" ]; then
    mkdir -p /var/www/storage /var/www/public_shared
    chown -R www-data:www-data /var/www/storage
    chown -R www-data:www-data /var/www/public_shared

    cp -rf /var/www/public/. /var/www/public_shared/
    chown -R www-data:www-data /var/www/public_shared
fi

if ! git config --global --get-all safe.directory | grep -q "/var/www"; then
    git config --global --add safe.directory /var/www
fi

until php artisan db:monitor > /dev/null 2>&1; do
  sleep 2
done

php artisan migrate --force
php artisan db:seed --class=AdminSeeder --force

if [ "$APP_ENV" = "production" ]; then
    php artisan config:cache
    php artisan route:cache
fi

chown www-data:www-data /proc/self/fd/1 /proc/self/fd/2 || true

if [ "$(id -u)" = '0' ]; then
    exec setpriv --reuid=www-data --regid=www-data --clear-groups "$@"
else
    exec "$@"
fi
