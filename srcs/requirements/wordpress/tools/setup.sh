#!/bin/bash

set -e

echo "Starting WordPress..."

# Read secrets

WP_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
WP_USER_PASSWORD="$(cat /run/secrets/wp_user_password)"
WORDPRESS_DB_PASSWORD="$(cat /run/secrets/wp_db_password)"

# Database settings

DB_HOST="mariadb:3306"

mkdir -p /var/www/html
cd /var/www/html

# Download WordPress if not already present

if [ ! -f wp-load.php ]; then
    echo "Downloading WordPress..."
    wp core download 
    --path=/var/www/html 
    --allow-root
fi

# Wait for MariaDB

echo "Waiting for MariaDB..."

until mariadb 
    -h"${DB_HOST}" 
    -u"${MYSQL_USER}" 
    -p"${WORDPRESS_DB_PASSWORD}" 
    "${MYSQL_DATABASE}" 
    -e "SELECT 1;" >/dev/null 2>&1
do
    echo "MariaDB is not ready. Waiting..."
    sleep 2
done

echo "MariaDB is ready."

# Create wp-config.php

if [ ! -f wp-config.php ]; then
echo "Creating wp-config.php..."


wp config create \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="${WORDPRESS_DB_PASSWORD}" \
    --dbhost="${DB_HOST}" \
    --path=/var/www/html \
    --allow-root


fi

# Install WordPress

if ! wp core is-installed 
--path=/var/www/html 
--allow-root >/dev/null 2>&1
then
echo "Installing WordPress..."


wp core install \
    --path=/var/www/html \
    --url="https://${DOMAIN_NAME}" \
    --title="${WP_SITE_NAME}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root


fi

# Create normal WordPress user

if ! wp user get "${WP_USER}" 
--path=/var/www/html 
--allow-root >/dev/null 2>&1
then
echo "Creating WordPress user..."


wp user create \
    "${WP_USER}" \
    "${WP_USER_EMAIL}" \
    --role=author \
    --user_pass="${WP_USER_PASSWORD}" \
    --path=/var/www/html \
    --allow-root


fi

# Set permissions

echo "Setting permissions..."

chown -R www-data:www-data /var/www/html

find /var/www/html -type d -exec chmod 755 {} ;
find /var/www/html -type f -exec chmod 644 {} ;

echo "WordPress setup complete."

# Start PHP-FPM

exec php-fpm8.2 -F
