NAME = inception

.PHONY: all down build clean re

all:
	@docker-compose -f srcs/docker-compose.yml up -d

down:
	@docker-compose -f srcs/docker-compose.yml down

build:
	@docker-compose -f srcs/docker-compose.yml build

clean:
	@docker-compose -f srcs/docker-compose.yml down -v

re:
	make down
	make build
