# Developer Documentation

## 1. Environment Setup (from scratch)

### Requirements

Ensure the following are installed:

- `Docker`
- `Docker Compose` (version 2+)
- `Make`
- `Git`

### Directory structure

The directory structure aims to keep a clean and maintainable project. It ensures correct separation of services and reproducible builds, making multi-service management easier. The Dockerfiles, configs and scripts files are cleanly separated.

```txt
.
├── Makefile
├── srcs/
│   ├── docker-compose.yaml
│   ├── requirements/
│   │   ├── mariadb/
│   │   │   ├── conf/
│   │   │   │   └── 50-server.cnf
│   │   │   ├── Dockerfile
│   │   │   └── tools/
│   │   │       └── mariadb-run.sh
│   │   ├── nginx/
│   │   │   ├── conf/
│   │   │   │   └── nginx.conf
│   │   │   └── Dockerfile
│   │   └── wordpress/
│   │       ├── conf/
│   │       │   └── www.conf
│   │       ├── Dockerfile
│   │       └── tools/
│   │           └── wp-install.sh
│   └── .env
├──USER_DOC.md
├──DEV_DOC.md
└──README.md
```

### Mandatory host directories

The subject requires persistent data to be stored in:

`/home/mariaoli/data/mariadb`  
`/home/mariaoli/data/wordpress`  

If they don't exist, they will be created automatically via the `Makefile`.

## 2. Configuration Files

### `.env`

Contains:

- Database credentials
- `WordPress` admin credentials
- Project configuration values

Example:

```txt
MYSQL_ROOT_PASSWORD=...
MYSQL_DATABASE=...
MYSQL_USER=...
MYSQL_PASSWORD=...
WP_ADMIN=...
WP_ADMIN_PASS=...
WP_EMAIL=...
```

> [!IMPORTANT]
> Never commit `.env` containing real credentials


## 3. Build and Launch the Project

### Using Makefile (recommended)

```bash
make
```

This will:  
- Build custom images from `Dockerfiles` (no official images allowed)
- Create containers
- Start the stack in detached mode

Using `Docker Compose`:
```bash
docker compose up --build -d
```

Rebuilding a single service, e.g. `NGINX`:
```bash
docker compose up --build -d nginx
```

## 4. Managing Containers

List active containers:
```bash
docker ps
```

Stop the stack:
```bash
docker compose down
```

Remove containers + volumes:
```bash
docker compose down -v
```

View logs:
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Access container shells:
```bash
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash
```

## 5. Managing Volumes and Persistent Data

List volumes:
```bash
docker volume ls
```
Expected output:
```bash
DRIVER    VOLUME NAME
local     srcs_v_db
local     srcs_v_web
```
Inspect volume:
```bash
docker volume inspect srcs_v_db
```
You should see:
```bash
"device": "/home/mariaoli/data/mariadb"
```

Rebuilding containers while keeping user data:
```bash
docker compose up --build -d
```

Rebuilding from zero (destroying data):
```bash
docker compose down -v
rm -rf /home/mariaoli/data/*
make up
```

## 6. Project Data Persistence

Data persists outside containers through bind mounts:  

WordPress files:  
`/home/mariaoli/data/wordpress`  
MariaDB database storage:  
`/home/mariaoli/data/mariadb`  

This allows:
- Full environment recreation
- No data loss when containers are deleted
- Easy backup from the host machine
