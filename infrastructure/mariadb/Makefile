# This Makefile requires GNU Make.
MAKEFLAGS += --silent

# Settings
C_BLU='\033[0;34m'
C_GRN='\033[0;32m'
C_RED='\033[0;31m'
C_YEL='\033[0;33m'
C_END='\033[0m'

include ../../.env

DOCKER_PROJ="$(PROJECT_NAME) - DATABASE"
DOCKER_ABBR=$(PROJECT_ABBR)
DOCKER_HOST=$(PROJECT_HOST)
DOCKER_IMGK=$(DATABASE_IMGK)
DOCKER_CAAS=$(DATABASE_CAAS)
DOCKER_PORT=$(DATABASE_PORT)

MYSQL_ROOT=$(DATABASE_ROOT)
MYSQL_NAME=$(DATABASE_NAME)
MYSQL_USER=$(DATABASE_USER)
MYSQL_PASS=$(DATABASE_PASS)

CURRENT_DIR=$(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
DIR_BASENAME=$(shell basename $(CURRENT_DIR))
ROOT_DIR=$(CURRENT_DIR)

DOCKER_COMPOSE?=$(DOCKER_USER) docker compose
DOCKER_COMPOSE_RUN=$(DOCKER_COMPOSE) run --rm
DOCKER_EXEC_TOOLS_APP=$(DOCKER_USER) docker exec -it $(DOCKER_CAAS) sh

help: ## shows this Makefile help message
	echo 'usage: make [target]'
	echo
	echo 'targets:'
	egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

# -------------------------------------------------------------------------------------------------
#  System
# -------------------------------------------------------------------------------------------------
.PHONY: port-check

port-check: ## shows this project port availability on local machine
	echo "Checking configuration for "${C_YEL}"$(DOCKER_PROJ)"${C_END}" container:";
	if [ -z "$$($(DOCKER_USER) lsof -i :$(DOCKER_PORT))" ]; then \
		echo ${C_BLU}"$(DOCKER_PROJ)"${C_END}" > port:"${C_GRN}"$(DOCKER_PORT) is free to use."${C_END}; \
    else \
		echo ${C_BLU}"$(DOCKER_PROJ)"${C_END}" > port:"${C_RED}"$(DOCKER_PORT) is busy. Update ./.env file."${C_END}; \
	fi

# -------------------------------------------------------------------------------------------------
#  Enviroment
# -------------------------------------------------------------------------------------------------
.PHONY: env env-set

env: ## checks if docker .env file exists
	if [ -f ./docker/.env ]; then \
		echo ${C_BLU}$(DOCKER_PROJ)${C_END}" docker-compose.yml .env file "${C_GRN}"is set."${C_END}; \
    else \
		echo ${C_BLU}$(DOCKER_PROJ)${C_END}" docker-compose.yml .env file "${C_RED}"is not set."${C_END}" \
	Create it by executing "${C_YEL}"$$ make env-set"${C_END}; \
	fi

env-set:
	echo "COMPOSE_PROJECT_ABBR=\"$(DOCKER_ABBR)\"\
	\nCOMPOSE_PROJECT_IMGK=\"$(DOCKER_IMGK)\"\
	\nCOMPOSE_PROJECT_NAME=\"$(DOCKER_CAAS)\"\
	\nCOMPOSE_PROJECT_HOST=\"$(DOCKER_HOST)\"\
	\nCOMPOSE_PROJECT_PORT=$(DOCKER_PORT)\
	\nMYSQL_ROOT_PASSWORD=\"$(MYSQL_ROOT)\"\
	\nMYSQL_DATABASE=$(MYSQL_NAME)\
	\nMYSQL_USER=$(MYSQL_USER)\
	\nMYSQL_PASSWORD=\"$(MYSQL_PASS)\""> ./docker/.env;
	echo ${C_BLU}"$(DOCKER_PROJ)"${C_END}" docker-compose.yml .env file "${C_GRN}"has been set."${C_END};

# -------------------------------------------------------------------------------------------------
#  Container
# -------------------------------------------------------------------------------------------------
.PHONY: container-ip ssh build install dev up start first stop restart clear

container-ip:
	$(DOCKER_USER) docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(DOCKER_CAAS)

ssh: ## enters the container shell
	$(DOCKER_EXEC_TOOLS_APP)

build: ## builds the container from Dockerfile
	cd docker && $(DOCKER_COMPOSE) up --build --no-recreate -d

up: ## attaches to containers for a service and also starts any linked services
	cd docker && $(DOCKER_COMPOSE) up -d

start: ## starts the container running
	cd docker && $(DOCKER_COMPOSE) start

stop: ## stops the container running - data won't be destroyed
	cd docker && $(DOCKER_COMPOSE) stop

restart: ## execute this Makefile "stop" & "start" recipes
	$(MAKE) stop start

clear: ## removes container from Docker running containers
	cd docker && $(DOCKER_COMPOSE) kill || true
	cd docker && $(DOCKER_COMPOSE) rm --force || true
	cd docker && $(DOCKER_COMPOSE) down -v --remove-orphans || true

destroy: ## delete container image from Docker - Docker prune commands still needed to be applied manually
	cd docker && $(DOCKER_USER) docker rmi -f $(DOCKER_CAAS):$(DOCKER_ABBR)$(DOCKER_IMGK)

dev: ## set a development enviroment
	echo ${C_YEL}"\"dev\" recipe has not usage in this project"${C_END};