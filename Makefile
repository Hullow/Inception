COMPOSE = docker compose -f srcs/docker-compose.yml --env-file srcs/.env
DATA_DIR = /home/fallan/data

all: up

prepare:
	mkdir -p $(DATA_DIR)/db $(DATA_DIR)/wp

up: prepare
	$(COMPOSE) up --detach --build

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
