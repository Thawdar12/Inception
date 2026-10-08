NAME = inception

COMPOSE = docker compose
COMPOSE_FILE = ./srcs/docker-compose.yml

DATA_DIR = /home/tswe-zin/data
DB_DIR = $(DATA_DIR)/mariadb
WP_DIR = $(DATA_DIR)/wordpress

.PHONY: all build up down clean fclean re logs

all: up

up:
	@mkdir -p $(DB_DIR) $(WP_DIR)
	$(COMPOSE) -f $(COMPOSE_FILE) up -d

build:
	@mkdir -p $(DB_DIR) $(WP_DIR)
	$(COMPOSE) -f $(COMPOSE_FILE) build

down:
	$(COMPOSE) -f $(COMPOSE_FILE) down

clean:
	$(COMPOSE) -f $(COMPOSE_FILE) down -v

fclean:
	$(COMPOSE) -f $(COMPOSE_FILE) down -v --rmi all --remove-orphans
	sudo rm -rf $(DATA_DIR)

re: fclean all

logs:
	$(COMPOSE) -f $(COMPOSE_FILE) logs -f