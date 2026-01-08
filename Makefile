COMPOSE = docker compose -f srcs/docker-compose.yml --env-file srcs/.env

all: up

up:
	$(COMPOSE) up --detach --build

attached:
	down
	$(COMPOSE) up --build

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
