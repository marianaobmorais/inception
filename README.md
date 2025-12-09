*This project has been created as part of the 42 curriculum by mariaoli*.

# Inception

## Description

Inception is a system administration and containerization project designed to introduce the fundamental concepts of `Docker` and **infrastructure-as-code**.

The goal of this project is to build a small, reproducible, and secure infrastructure using `Docker`, `Docker Compose`, and custom `Dockerfiles` — **without using any official images**.

The system consists of three main services:
- **NGINX with TLS (port 443)** – serves as the web server
- **WordPress + PHP-FPM** - runs the website
- **MariaDB** – provides the database

Each service runs in its own containers, communicates through Docker networks, and persists data using volumes stored inside the user’s home directory.

The entire setup was built from scratch using `Debian Bookworm` and custom configuration.

### Architecture overview:

```txt
                          +---------------------+
                          |      Internet       |
                          +----------+----------+
                                     |
                           Exposed Port: 443
                                     |
                           (Docker Bridge Network)
                                     |
                         +-----------▼-----------+
                         |        NGINX          |
                         |    TLS termination    |
                         |   /etc/nginx/conf.d   |
                         +-----------+-----------+
                                     |
                                     | FastCGI (internal-only)
                                     |
                     +---------------▼---------------+
                     |      WordPress + PHP-FPM      |
                     |  /var/www/html (bind mount)   |
                     |   Runs PHP + WP core          |
                     +---------------+---------------+
                                     |
                                     | 3306 (internal-only)
                                     |
                         +-----------▼-----------+
                         |        MariaDB         |
                         | /var/lib/mysql (bind)  |
                         |   Stores WP database   |
                         +-----------+-----------+

Persistent Data (bind mounts):
- /home/mariaoli/data/wordpress  → WordPress files
- /home/mariaoli/data/mariadb    → MariaDB database

```

## Features

### Infrastructure as Code (IaC)

IaC is the equipping and management of IT infrastructure using code instead of manual processes. Defining infrastructure in machine-readable files allows for work automation, version control, and repeatable deployments of resources like virtual machines, networks, and databases, which reduces errors and speeds up development cycle.

### Docker

Docker provides isolated containers for each service. It provides the lower-level tools to run containers.

Key characteristics:
- Each service has its own `Dockerfile` (no official images)
- Services communicate only through `Docker networks`
- Persistent data lives inside bind-mounted folders in the user’s home directory:
  - /home/mariaoli/data/mariadb
  - /home/mariaoli/data/wordpress
- A Makefile or simple commands allow the entire infrastructure to be recreated from scratch in seconds

Use `Docker` alone when:
- Running a single container
- Experimenting or debugging low-level behavior
- Customizing command-line options

### Docker Compose

`Docker Compose` is a higher-level tool that automates the creation of multiple containers (services) and their relationships. It is an orchestrator.

Key characteristics:
- Defines and orchestrates all services and networks in one file
- Automatically creates volumes and networks
- Simplifies start/stop and ensures reproducible environments

Use `Docker Compose` when:
- Using multiple services (e.g., WordPress + MariaDB + NGINX)
- Needing automatic network/volume setup
- Wanting easy start/stop of the full stack
- Wanting reproducible development environments

### Docker Image

A `Docker image` is composed of filesystem snapshot, metadata (`ENTRYPOINT`, `CMD`, `ENV`, `EXPOSE`…) and layers. The image is exactly the same whether you run it with docker compose or with plain docker run. The difference is in how the container is started, configured, and connected.

> **Summary:** Docker runs containers. Compose manages groups of containers. Compose depends on Docker; Docker does not depend on Compose. The image is exactly the same whether you run it with `docker compose` or with plain `docker`.

## Design Choices

### Virtual Machines vs Docker Containers

| Virtual Machines | Docker Containers |
|---|---|
| Heavyweight, include full OS | Lightweight, share host kernel |
| Slow to boot | Does not need to boot, start in milliseconds |
| Take up a lot of resources | Efficient and minimal |
| Strong isolation, cannot interact with their host | Process-level isolation, can interact with their host |
| Perfect for long-running full systems | Perfect for microservices and dev workflows |

The subject asks us to work with Docker so we can learn how to build a fast, lightweight, and reproducible environment.

### Docker Network vs Host Network

| Docker Network | Host Network |
|---|---|
| Containers get isolated virtual interfaces | Containers share the host network namespace |
| Easy to control communication | Less secure, no isolation |
| Recommended for microservices | Useful for low latency workloads |

This project uses a Docker bridge network, allowing 1. internal traffic between WordPress and MariaDB; and 2. NGINX reachable from the host only on the exposed ports

### Secrets vs Environment Variables

| Environment Variables | Secrets |
|---|---|
| Easy to use | Secure by design |
| Stored in plain text in the container | Encrypted and managed by Docker |
| Suitable for non-sensitive config | Suitable for passwords, keys, certificates |

This project uses environment variables, a simple and straight forward approach for a small, low-impact project. Docker secrets require Swarm mode, an encryption tool that is strongly recommended for real production systems.

### Docker Volumes vs Bind Mounts

| Volumes | Bind Mounts |
|---|---|
| Stored under /var/lib/docker/volumes/... | Can map any host directory |
| Managed by Docker | Managed by user |
| Better security and portability | More flexible, less predictable |
| Slower to inspect manually | Great for local development |
| Used for persistent data that must survive container deletion | Mirror a specific host directory inside a container |

For this project, Docker volumes ensure persistent data lives in `/home/mariaoli/data/mariadb` for MariaDB data and in `/home/mariaoli/data/wordpress` for WordPress data. Persistence and data integrity can be easily confirmed through accessing these folders.

## Instructions

### Build

Clone the repository:
```shell
git clone https://github.com/mariaoli/inception.git
```

Enter the cloned directory:
```shell
cd inception
```

Run `make` to build and start the infrastructure:
```shell
make up
```

### Usage

Access services:
```txt
To test WordPress, enter in the browser: https://mariaoli.42.fr
```

NGINX redirect test:
In the terminal, run:
```shell
curl -v http://localhost:80 → should not work
```

MariaDB: from inside the container
```shell
docker exec -it mariadb mysql -u root -p
```

Stop and clean (containers only):
```shell
make down
```

Stop and remove containers + volumes:
```shell
make clean
```

## Resources

### Documentation & References

Learning Docker: https://www.linkedin.com/learning/learning-docker-17236240  
Docker documentation: https://docs.docker.com/  
MariaDB docs: https://mariadb.com/kb  
NGINX configuration: https://nginx.org/en/docs/  
WordPress-CLI (WP-CLI): https://wp-cli.org/  
WordPress Codex: https://developer.wordpress.org/  
Tutorial: https://github.com/pin3dev/42_Inception/wiki  

### Use of AI

AI was used for:  
- Clarifying Docker concepts (networks, bind mounts, volumes, TLS)
- Explaining errors during build/run and debugging
- Improving the structure of this README and drawing the diagram
- AI was not used to generate project code directly, in compliance with 42 rules
- All scripts, Dockerfiles, and configuration files were written by me