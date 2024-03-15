# This Makefile requires GNU Make.
MAKEFLAGS += --silent

# Settings
C_BLU='\033[0;34m'
C_GRN='\033[0;32m'
C_RED='\033[0;31m'
C_YEL='\033[0;33m'
C_END='\033[0m'

include .env

DOCKER_TITLE=$(PROJECT_TITLE)

CURRENT_DIR=$(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
DIR_BASENAME=$(shell basename $(CURRENT_DIR))
ROOT_DIR=$(CURRENT_DIR)

help: ## shows this Makefile help message
	echo 'usage: make [target]'
	echo
	echo 'targets:'
	egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

# -------------------------------------------------------------------------------------------------
#  System
# -------------------------------------------------------------------------------------------------
.PHONY: hostname fix-permission host-check

hostname: ## shows local machine ip
	echo $(word 1,$(shell hostname -I))

fix-permission: ## sets project directory permission
	$(DOCKER_USER) chown -R ${USER}: $(ROOT_DIR)/

ports-check: ## shows this project ports availability on local machine
	cd docker/nginx-php && $(MAKE) port-check
	cd docker/mariadb && $(MAKE) port-check

# -------------------------------------------------------------------------------------------------
#  Database Service
# -------------------------------------------------------------------------------------------------
.PHONY: database-ssh database-set database-build database-start database-stop database-destroy database-replace database-backup

database-ssh: ## enters the database container shell
	cd docker/mariadb && $(MAKE) ssh

database-set: ## sets the database enviroment file to build the container
	cd docker/mariadb && $(MAKE) env-set

database-build: ## builds the database container from Docker image
	cd docker/mariadb && $(MAKE) build

database-start: ## starts up the database container running
	cd docker/mariadb && $(MAKE) up

database-stop: ## stops the database container but data won't be destroyed
	cd docker/mariadb && $(MAKE) stop

database-destroy: ## stops and removes the database container from Docker network destroying its data
	cd docker/mariadb && $(MAKE) stop clear

database-install: ## installs an initialized database copying the determined .sql file into the container by raplacing it
	cd docker/mariadb && $(MAKE) sql-install
	echo ${C_BLU}"$(DOCKER_TITLE)"${C_END}" database has been "${C_GRN}"installed."${C_END};

database-replace: ## replaces container database copying the determined .sql file into the container by raplacing it
	cd docker/mariadb && $(MAKE) sql-replace
	echo ${C_BLU}"$(DOCKER_TITLE)"${C_END}" database has been "${C_GRN}"replaced."${C_END};

database-backup: ## creates a .sql file from container database to the determined local host directory
	cd docker/mariadb && $(MAKE) sql-backup
	echo ${C_BLU}"$(DOCKER_TITLE)"${C_END}" database "${C_GRN}"backup has been created."${C_END};

# -------------------------------------------------------------------------------------------------
#  Laravel & Database
# -------------------------------------------------------------------------------------------------
.PHONY: project-set project-build project-start project-stop project-destroy

project-set: ## sets both Laravel and database .env files used by docker-compose.yml
	$(MAKE) laravel-set database-set

project-build: ## builds both Laravel and database containers from their Docker images
	$(MAKE) laravel-set database-set database-build laravel-build

project-start: ## starts up both Laravel and database containers running
	$(MAKE) database-start laravel-start

project-stop: ## stops both Laravel and database containers but data won't be destroyed
	$(MAKE) database-stop laravel-stop

project-destroy: ## stops and removes both Laravel and database containers from Docker network destroying their data
	$(MAKE) database-destroy laravel-destroy

# -------------------------------------------------------------------------------------------------
#  Repository Helper
# -------------------------------------------------------------------------------------------------
repo-flush: ## clears local git repository cache specially to update .gitignore
	git rm -rf --cached .
	git add .
	git commit -m "fix: cache cleared for untracked files"

# -------------------------------------------------------------------------------------------------
#  Laravel Service
# -------------------------------------------------------------------------------------------------
.PHONY: laravel-ssh laravel-set laravel-build laravel-start laravel-stop laravel-destroy

laravel-ssh: ## enters the Laravel container shell
	cd docker/nginx-php && $(MAKE) ssh

laravel-set: ## sets the Laravel PHP enviroment file to build the container
	cd docker/nginx-php && $(MAKE) env-set

laravel-build: ## builds the Laravel PHP container from Docker image
	cd docker/nginx-php && $(MAKE) build

laravel-start: ## starts up the Laravel PHP container running
	cd docker/nginx-php && $(MAKE) up

laravel-stop: ## stops the Laravel PHP container but data won't be destroyed
	cd docker/nginx-php && $(MAKE) stop

laravel-destroy: ## stops and removes the Laravel PHP container from Docker network destroying its data
	cd docker/nginx-php && $(MAKE) stop clear