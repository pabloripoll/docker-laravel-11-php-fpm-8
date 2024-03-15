# This Makefile requires GNU Make.
MAKEFLAGS += --silent

# Settings
C_BLU='\033[0;34m'
C_GRN='\033[0;32m'
C_RED='\033[0;31m'
C_YEL='\033[0;33m'
C_END='\033[0m'

include ../../.env

DOCKER_TITLE="$(PROJECT_TITLE) DB"
DOCKER_ABBR=$(PROJECT_ABBR)
DOCKER_CAAS=$(PROJECT_DB_CAAS)
DOCKER_HOST=$(PROJECT_DB_HOST)
DOCKER_PORT=$(PROJECT_DB_PORT)

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

env-set:
	echo "COMPOSE_PROJECT_ABBR=\"$(DOCKER_ABBR)\"\
	\nCOMPOSE_PROJECT_NAME=\"$(DOCKER_CAAS)\"\
	\nCOMPOSE_PROJECT_PORT=$(DOCKER_PORT)\
	\nMYSQL_ROOT_PASSWORD=\"$(PROJECT_DB_ROOT)\"\
	\nMYSQL_DATABASE=$(PROJECT_DB_NAME)\
	\nMYSQL_USER=$(PROJECT_DB_USER)\
	\nMYSQL_PASSWORD=\"$(PROJECT_DB_PASS)\""> ./docker/.env;
	echo ${C_BLU}"$(DOCKER_TITLE)"${C_END}" docker-compose.yml .env file "${C_GRN}"has been set."${C_END};

# -------------------------------------------------------------------------------------------------
#  Container
# -------------------------------------------------------------------------------------------------
.PHONY: ssh build dev up first start stop clear restart rebuild

ssh:
	$(DOCKER_EXEC_TOOLS_APP)

build:
	cd docker && $(DOCKER_COMPOSE) up --build --no-recreate -d

dev:
	echo ${C_YEL}"\"dev\" recipe has not usage in this project"${C_END};

up:
	cd docker && $(DOCKER_COMPOSE) up -d

first:
	$(MAKE) build install up

start:
	$(MAKE) build up

stop:
	cd docker && $(DOCKER_COMPOSE) kill || true
	cd docker && $(DOCKER_COMPOSE) rm --force || true

clear:
	cd docker && $(DOCKER_COMPOSE) down -v --remove-orphans || true

restart:
	$(MAKE) stop start

rebuild:
	$(MAKE) stop clear start

# -------------------------------------------------------------------------------------------------
#  Container
# -------------------------------------------------------------------------------------------------
.PHONY: sql-install sql-replace sql-backup

sql-install:
	sudo docker exec -i $(PROJECT_DB_CAAS) sh -c 'exec mysql $(PROJECT_DB_NAME) -uroot -p"$(PROJECT_DB_ROOT)"' < $(PROJECT_DB_PATH)/$(PROJECT_DB_NAME)-init.sql

sql-replace:
	sudo docker exec -i $(PROJECT_DB_CAAS) sh -c 'exec mysql $(PROJECT_DB_NAME) -uroot -p"$(PROJECT_DB_ROOT)"' < $(PROJECT_DB_PATH)/$(PROJECT_DB_NAME)-backup.sql

sql-backup:
	sudo docker exec $(PROJECT_DB_CAAS) sh -c 'exec mysqldump $(PROJECT_DB_NAME) -uroot -p"$(PROJECT_DB_ROOT)"' > $(PROJECT_DB_PATH)/$(PROJECT_DB_NAME)-backup.sql