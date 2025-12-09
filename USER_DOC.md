# User Documentation

## Overview

This project provides a fully containerized web stack composed of:

- **NGINX** — HTTPS reverse proxy (port 443), TLS enabled
- **WordPress** — PHP-based website running with PHP-FPM 8.2
- **MariaDB** — Database used by WordPress

All services run as isolated Docker containers and communicate through an internal Docker network.  
User data (WordPress uploads, database contents) is stored persistently on the host machine inside:  

`/home/mariaoli/data/wordpress`  
`/home/mariaoli/data/mariadb`  


## 1. Starting the Project

At the root of the repository:

```bash
make up
```

This command:
- Builds all `Docker images` from custom `Dockerfiles`
- Creates containers
- Starts the infrastructure in `daemon` mode

## 2. Stopping the Project

To stop containers without deleting data:
```bash
make down
```

Or:
```bash
docker compose down
```

To delete containers and persistent data:
```bash
make fclean
```

## 3. Accessing the Website & Admin Panel

### WordPress Website

Open your browser:
```txt
https://mariaoli.42.fr
```

NGINX is configured for HTTPS through `port 443`; plain HTTP `http://localhost` will also work because the browser automatically forces HTTPS, which is a more secure protocol.

If you want to try the NGINX purely without interference of the auto-redirect of the browser, try accessing HTTP via terminal:
```bash
curl -v http://localhost:80
```

### WordPress Admin Panel

Type in your browser:
```txt
https://mariaoli.42.fr/wp-admin
```

Use the admin credentials set during `WordPress` installation (it is stored in the ``.env file).

## 4. Locating and Managing Credentials

Your credentials are stored in:
```bash
./srcs/.env
```

The `.env` file includes:
- WordPress admin username/password
- Database user/password
- Database name
- Host configuration
- and other sensitive information

If you need to rotate passwords, update the values in `.env`

Rebuild only the affected containers:
```bash
docker compose up -d --build --force-recreate
```
> [!IMPORTANT]
> Never commit `.env` containing real credentials

## 5. Checking That Services Are Running

### Using Docker commands

#### Check Containers

Run:
```bash
docker ps
```
You should see something like that:
```bash
CONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS          PORTS                                     NAMES
606e3299c2c1   nginx            "nginx -g 'daemon of…"   13 seconds ago   Up 12 seconds   0.0.0.0:443->443/tcp, [::]:443->443/tcp   nginx
a583c063658a   wordpress        "./wp-install.sh"        13 seconds ago   Up 13 seconds   9000/tcp                                  wordpress
b0fd376842bf   mariadb          "./mariadb-run.sh"       14 seconds ago   Up 13 seconds   3306/tcp                                  mariadb
```

#### Check logs

To see the Containers logs run:
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

#### Access database container
```bash
docker exec -it mariadb mysql -u root -p  # in order to access, you will need to enter MariaDb root password define in the .env file
```
Once inside MariaDB environment, enter:
```sql
SHOW DATABASES;
```
It will show you something like:
```bash
+--------------------+ 
| Database           | 
+--------------------+ 
| dbsite             | 
| information_schema | 
| mysql              | 
| performance_schema | 
| sys                | 
+--------------------+ 
5 rows in set (0.001 sec)
```
Then, select `WordPress` database:
```sql
USE dbsite;
```
List tables in the database:
```sql
SHOW TABLES;
```
Check contents of a table:
```sql
SELECT * FROM wp_users;
```
Check table structure:
```sql
DESCRIBE wp_users;
```

### Verify WordPress is responding 
Visit:  
```txt
https://mariaoli.42.fr  
```
If the page loads, `WordPress + PHP-FPM` + `MariaDB` + `NGINX` are all functioning.

## 6. Where Data Is Stored

Your persistent data is stored on the host, not inside the containers:  
`/home/mariaoli/data/mariadb`      → database tables  
`/home/mariaoli/data/wordpress`    → WordPress files, uploads  

Deleting containers does not delete these folders:  
```bash
ls /home/mariaoli/data/mariadb
ls /home/mariaoli/data/wordpress
```
