#!/bin/sh
set -e

echo "🚀 Starting Laravel container as $(whoami)..."

if ! git config --global --get-all safe.directory | grep -q "/var/www"; then
    git config --global --add safe.directory /var/www
fi

# Ensure Laravel directories
for dir in bootstrap/cache storage storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
done

# Ensure tmp directories (Laravel cache)
for dir in "${SESSION_FILES_PATH:-/tmp/laravel-sessions}" "${VIEW_COMPILED_PATH:-/tmp/laravel-views}" "${CACHE_FILE_PATH:-/tmp/laravel-cache}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
done

exec "$@"
