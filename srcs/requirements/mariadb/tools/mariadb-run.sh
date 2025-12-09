#!/bin/bash

# Create initialization SQL
cat << EOF > /etc/mysql/init.sql
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Ensure database directory exists
mkdir -p /var/lib/mysql

# Initialize database
mariadb-install-db --ldata=/var/lib/mysql

# Start mariadb using the init script
exec mysqld --init-file=/etc/mysql/init.sql
