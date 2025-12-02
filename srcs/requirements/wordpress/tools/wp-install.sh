#!/bin/bash

# Wait for mariadb
echo "Waiting for MariaDB..."
until mysqladmin ping -h"$DB_HOST" --silent; do
    sleep 2
done
echo "MariaDB is up!"

cd /var/www/html

# Download WP-CLI if not already present
if [ ! -f wp-cli.phar ]; then
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
fi

WP="./wp-cli.phar"

# Download wordpress core if not already present
if [ ! -f wp-config-sample.php ]; then
	$WP core download --allow-root
fi

# Create wp-config.php if not already present
if [ ! -f wp-config.php ]; then
	$WP config create \
		--dbname="$DB_NAME" \
		--dbuser="$DB_USER" \
		--dbpass="$DB_PASSWORD" \
		--dbhost="$DB_HOST" \
		--allow-root
fi

# Install wordpress if not already present
if ! $WP core is-installed --allow-root >/dev/null 2>&1; then
       $WP core install \
	       --url="$WP_DOMAIN" \
	       --title="$WP_TITLE" \
	       --admin_user="$WP_ADMIN_USER" \
	       --admin_password="$WP_ADMIN_PASSWORD" \
	       --admin_email="$WP_ADMIN_EMAIL" \
	       --allow-root
fi

# Create guest user if not already present
if ! $WP user get "$WP_GUEST_USER" --allow-root >/dev/null 2>&1; then
       $WP user create "$WP_GUEST_USER" "$WP_GUEST_EMAIL" \
	       --role=subscriber\
	       --user_pass="$WP_GUEST_PASSWORD" \
	       --allow-root
fi

# Start PHP-FPM in foreground
php-fpm8.2 -F
