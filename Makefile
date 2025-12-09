DOCKER_COMPOSE_BIN = docker compose
DOCKER_COMPOSE = $(DOCKER_COMPOSE_BIN) -f srcs/docker-compose.yaml

DATA_DIR = $(HOME)/data
MARIADB_DIR = $(DATA_DIR)/mariadb
WP_DIR = $(DATA_DIR)/wordpress

all: build

data:
	@mkdir -p $(MARIADB_DIR) $(WP_DIR)
@sudo chown -R 1000:1000 $(MARIADB_DIR) $(WP_DIR) || true

build: data
	$(DOCKER_COMPOSE) build

up: build
	$(DOCKER_COMPOSE) up -d

image:
	docker image ls

down:
	$(DOCKER_COMPOSE) down

ps:
	$(DOCKER_COMPOSE) ps

mariadb:
	docker exec -it mariadb bash
	# mysql -u root -p

clean:
	$(DOCKER_COMPOSE) down -v
	@echo "Cleaning dangling images..."
	@docker image prune -f

fclean: clean
	@echo "Removing data directory..."
	@sudo rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all data build up image down ps mariadb clean fclean re
