# Makefile for Docker shortcuts

# Default target: show help
.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  build      Build Docker images"
	@echo "  up         Start Docker containers (foreground)"
	@echo "  up-detach  Start Docker containers (detached mode)"
	@echo "  down       Stop and remove containers"
	@echo "  restart    Restart the app"
	@echo "  console    Run console in the app container"
	@echo "  bash       ssh into the app container"
	@echo "  rails      Run a Rails command inside the app container"
	@echo "  db-setup   Create and migrate the database"
	@echo "  rubocop    Run rubocop"
	@echo "  ps         List running containers"

# Build Docker images using docker-compose
.PHONY: build
build:
	docker-compose build

# Start Docker containers in the foreground
.PHONY: up
up:
	docker-compose up

# Start Docker containers in detached mode
.PHONY: up-detach
up-detach:
	docker-compose up -d

# Stop and remove Docker containers
.PHONY: down
down:
	docker-compose down

# Restart the app
.PHONY: restart
restart:
	make down
	make up

# Run console in the app container
.PHONY: console
console:
	docker-compose exec app rails console

# ssh into the app container
.PHONY: bash
bash:
	docker-compose exec app bash

# Run a Rails command in the app container
# Usage: make rails cmd="rails c" or any rails command you want.
.PHONY: rails
rails:
	docker-compose run $(cmd)

# Create and migrate the database
.PHONY: db-setup
db-setup:
	docker-compose run rails db:create db:migrate

# run rubocop
.PHONY: rubocop
rubocop:
	docker-compose run rubocop -a

# List running containers
.PHONY: ps
ps:
	docker-compose ps
