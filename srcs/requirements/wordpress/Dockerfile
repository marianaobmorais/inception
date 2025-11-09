# Base image
FROM debian:bookworm

# Install PHP, extensions and curl
RUN apt update && apt upgrade -y && \
	apt install -y php8.2-fpm php8.2-mysqli curl mariadb-client && \
	mkdir -p /run/php && chown -R www-data:www-data /run/php

# Copy custom PHP-FPM pool configuration
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/.

# Copy WordPress install script and make it executable
COPY ./tools/wp-install.sh .
RUN chmod +x wp-install.sh

# /use script as entrypoint
ENTRYPOINT ["./wp-install.sh"]
