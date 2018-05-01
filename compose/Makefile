export COMPOSE_PROJECT_NAME ?= rdssdatavault

all: destroy build up list

build:  ## Build images
	docker-compose build

up:  ## Start containers
	docker-compose up -d

list:  ## Show running containers
	docker-compose ps

watch: ## Show container logs
	docker-compose logs -f

down:  ## Stop running containers
	docker-compose down

destroy:  ## Stop running containers and destroy data volumes
	docker-compose down -v

.PHONY: all build destroy down list up watch

help:  ## Print this help message.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
