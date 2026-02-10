#!/bin/sh
set -e

CURRENT_UID="$(id -u)"
CURRENT_GID="$(id -g)"

echo "🚀 Starting Laravel container..."

# ----------------------------
# Fix Git dubious ownership
# ----------------------------
git config --global --add safe.directory /var/www

# ----------------------------
# Ensure Laravel directories
# ----------------------------
for dir in bootstrap/cache storage storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs; do
    mkdir -p "$dir"
    chown -R "${CURRENT_UID}:${CURRENT_GID}" "$dir" 2>/dev/null || true
    chmod -R ug+rwx "$dir"
done

# ----------------------------
# Ensure tmp directories (Laravel cache)
# ----------------------------
for dir in "${SESSION_FILES_PATH:-/tmp/laravel-sessions}" "${VIEW_COMPILED_PATH:-/tmp/laravel-views}" "${CACHE_FILE_PATH:-/tmp/laravel-cache}"; do
    mkdir -p "$dir"
    chown "${CURRENT_UID}:${CURRENT_GID}" "$dir" 2>/dev/null || true
done

# ----------------------------
# Start main process (php-fpm)
# ----------------------------
exec "$@"
