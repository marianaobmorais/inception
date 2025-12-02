FROM debian:bookworm
RUN apt update && apt upgrade -y && apt install -y php8.2-fpm php8.2-mysqli curl mariadb-client
RUN mkdir -p /run/php && chown -R www-data:www-data /run/php
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/.
COPY ./tools/wp-install.sh .
RUN chmod +x wp-install.sh
ENTRYPOINT ["./wp-install.sh"]
