#!/bin/bash

cd /var/www/html

# Download the WordPress CLI (wp-cli) PHAR file if not installed
# This is the command-line tool for managing WordPress installations
if [ ! -f wp-cli.phar ]; then
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
fi

# Wait for mariaDB container to be ready
# Attempts to connect to the database in a loop
#until mariadb -h mariadb wpuser -ppassword -e "SELECT 1;" >/dev/null 2>&1; do
#	echo "Waiting for MariaDB..."
#	sleep 2
#done
sleep 5

echo "MariaDB is ready"

# Download the latest WordPress core files into the current directory if not installed
# --allow-root allows running WP-CLI as the root inside container
if [ ! -f wp-config.php ]; then
	./wp-cli.phar core download --allow-root

	# Create the wp-config.php file with database connection details
	./wp-cli.phar config create \
		--dbname=wordpress \
		--dbuser=wpuser \
		--dbpass=password \
		--dbhost=mariadb \
		--allow-root

	# Install WordPress with site settings
	./wp-cli.phar core install \
		--url=localhost \
		--title=inception \
		--admin_user=mariaoli \
		--admin_password=123456789 \
		--admin_email=mariaoli@inception.com \
		--allow-root

	# Create an additional WordPress user
	./wp-cli.phar user create guest guest@inception.com \
		--role=subscriber \
		--user_pass=123456789 \
		--allow-root
fi

# Start PHP-FPM in the foreground
# -F: run in the foreground to keep container alive
php-fpm8.2 -F
