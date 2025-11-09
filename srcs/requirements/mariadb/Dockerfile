FROM debian:bookworm
RUN apt update && apt upgrade -y && apt install -y mariadb-server
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/.
COPY tools/init.sql /docker-entrypoint-initdb.d/.
RUN mkdir /run/mysqld && chown -R mysql:mysql /run/mysqld
ENTRYPOINT ["mysqld_safe"]
