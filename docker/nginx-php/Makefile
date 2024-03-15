# This Makefile requires GNU Make.
MAKEFLAGS += --silent

# Settings
C_BLU='\033[0;34m'
C_GRN='\033[0;32m'
C_RED='\033[0;31m'
C_YEL='\033[0;33m'
C_END='\033[0m'

include ../../.env

DOCKER_TITLE=$(PROJECT_TITLE)
DOCKER_ABBR=$(PROJECT_ABBR)
DOCKER_CAAS=$(PROJECT_CAAS)
DOCKER_HOST=$(PROJECT_HOST)
DOCKER_PORT=$(PROJECT_PORT)
DOCKER_PATH=$(PROJECT_PATH)

CURRENT_DIR=$(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
DIR_BASENAME=$(shell basename $(CURRENT_DIR))
ROOT_DIR=$(CURRENT_DIR)

DOCKER_COMPOSE?=$(DOCKER_USER) docker compose
DOCKER_COMPOSE_RUN=$(DOCKER_COMPOSE) run --rm
DOCKER_EXEC_TOOLS_APP=$(DOCKER_USER) docker exec -it $(DOCKER_CAAS) sh

COMPOSER_UPDATE="composer update"

help: ## shows this Makefile help message
	echo 'usage: make [target]'
	echo
	echo 'targets:'
	egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

# -------------------------------------------------------------------------------------------------
#  System
# -------------------------------------------------------------------------------------------------
.PHONY: port-check

port-check: ## shows this project ports availability on local machine
	echo "Checking configuration for "${C_YEL}"$(DOCKER_TITLE)"${C_END}" container:";
	if [ -z "$$($(DOCKER_USER) lsof -i :$(DOCKER_PORT))" ]; then \
		echo ${C_BLU}"$(DOCKER_TITLE)"${C_END}" > port:"${C_GRN}"$(DOCKER_PORT) is free to use."${C_END}; \
    else \
		echo ${C_BLU}"$(DOCKER_TITLE)"${C_END}" > port:"${C_RED}"$(DOCKER_PORT) is busy. Update ./.env file."${C_END}; \
	fi

# -------------------------------------------------------------------------------------------------
#  Enviroment
# -------------------------------------------------------------------------------------------------
.PHONY: env env-set

env: ## checks if docker .env file exists
	if [ -f ./docker/.env ]; then \
		echo ${C_BLU}$(DOCKER_TITLE)${C_END}" docker-compose.yml .env file "${C_GRN}"is set."${C_END}; \
    else \
		echo ${C_BLU}$(DOCKER_TITLE)${C_END}" docker-compose.yml .env file "${C_RED}"is not set."${C_END}" \
	Create it by executing "${C_YEL}"$$ make env-set"${C_END}; \
	fi

env-set: ## sets docker .env file
	echo "COMPOSE_PROJECT_ABBR=\"$(DOCKER_ABBR)\"\
	\nCOMPOSE_PROJECT_NAME=\"$(DOCKER_CAAS)\"\
	\nCOMPOSE_PROJECT_HOST=$(DOCKER_HOST)\
	\nCOMPOSE_PROJECT_PORT=$(DOCKER_PORT)\
	\nCOMPOSE_PROJECT_PATH=\"$(DOCKER_PATH)\"" > ./docker/.env; \
	echo ${C_BLU}"$(DOCKER_TITLE)"${C_END}" docker-compose.yml .env file "${C_GRN}"has been set."${C_END};

# -------------------------------------------------------------------------------------------------
#  Container
# -------------------------------------------------------------------------------------------------
.PHONY: ssh build install update dev up start first stop restart clear

ssh:
	$(DOCKER_EXEC_TOOLS_APP)

build:
	cd docker && $(DOCKER_COMPOSE) up --build --no-recreate -d

install:
	cd docker && $(DOCKER_EXEC_TOOLS_APP) -c composer create-project laravel/laravel:^11.0 .

update:
	cd docker && $(DOCKER_EXEC_TOOLS_APP) -c $(COMPOSER_INSTALL)

dev:
	echo ${C_YEL}"\"dev\" recipe has not usage in this project"${C_END};

up:
	cd docker && $(DOCKER_COMPOSE) up -d

start:
	$(MAKE) build up

first:
	$(MAKE) build install up

stop:
	cd docker && $(DOCKER_COMPOSE) kill || true
	cd docker && $(DOCKER_COMPOSE) rm --force || true

restart:
	$(MAKE) stop start

clear:
	cd docker && $(DOCKER_COMPOSE) down -v --remove-orphans || true

# -------------------------------------------------------------------------------------------------
#  Container update on the run
# -------------------------------------------------------------------------------------------------
.PHONY: nginx-conf php-conf php-fpm-conf

nginx-conf:
	$(DOCKER_USER) docker run -v "`pwd`/nginx-server.conf:/etc/nginx/conf.d/server.conf" $(DOCKER_CAAS):$(DOCKER_ABBR)-nginx-php

php-conf:
	$(DOCKER_USER) docker run -v "`pwd`/php-setting.ini:/etc/php83/conf.d/settings.ini" $(DOCKER_CAAS)

php-fpm-conf:
	$(DOCKER_USER) docker run -v "`pwd`/php-fpm-settings.conf:/etc/php83/php-fpm.d/server.conf" $(DOCKER_CAAS)