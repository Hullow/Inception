COMPOSE = docker compose -f srcs/docker-compose.yml --env-file srcs/.env

DATA_DIR = /home/fallan/data
DB_DIR = $(DATA_DIR)/db
WP_DIR = $(DATA_DIR)/wp

all: up

up: $(DB_DIR) $(WP_DIR)
	$(COMPOSE) up --detach --build

attached: $(DB) $(WP_DIR)
	down
	$(COMPOSE) up --build

$(DB_DIR) $(WP_DIR):
	mkdir -p $@

# stop and remove containers and networks (default: but not volumes and images)
down:
	$(COMPOSE) down

build:
	$(COMPOSE) build

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

re: down up

.PHONY: all up down build ps logs re