#!/bin/sh
set -e

if ! git config --global --get-all safe.directory | grep -q "/var/www"; then
    git config --global --add safe.directory /var/www
fi

for dir in bootstrap/cache storage storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
done

for dir in "${SESSION_FILES_PATH:-/tmp/laravel-sessions}" "${VIEW_COMPILED_PATH:-/tmp/laravel-views}" "${CACHE_FILE_PATH:-/tmp/laravel-cache}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
done

until php artisan db:monitor > /dev/null 2>&1; do
  sleep 2
done

php artisan migrate --force
php artisan db:seed --class=AdminSeeder --force

php artisan config:cache
php artisan route:cache

exec "$@"
