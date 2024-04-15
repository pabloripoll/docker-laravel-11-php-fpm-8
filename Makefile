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
	echo $(ip addr show | grep "\binet\b.*\bdocker0\b" | awk '{print $2}' | cut -d '/' -f 1)

fix-permission: ## sets project directory permission
	$(DOCKER_USER) chown -R ${USER}: $(ROOT_DIR)/

host-check: ## shows this project ports availability on local machine
	cd docker/nginx-php && $(MAKE) port-check

# -------------------------------------------------------------------------------------------------
#  Application Service
# -------------------------------------------------------------------------------------------------
.PHONY: laravel-ssh laravel-set laravel-create laravel-start laravel-stop laravel-destroy laravel-install laravel-update

laravel-ssh: ## enters the application container shell
	cd docker/nginx-php && $(MAKE) ssh

laravel-set: ## sets the application PHP enviroment file to build the container
	cd docker/nginx-php && $(MAKE) env-set

laravel-create: ## creates the application PHP container from Docker image
	cd docker/nginx-php && $(MAKE) env-set build up

laravel-start: ## starts the application PHP container running
	cd docker/nginx-php && $(MAKE) start

laravel-stop: ## stops the application PHP container but data will not be destroyed
	cd docker/nginx-php && $(MAKE) stop

laravel-destroy: ## removes the application PHP from Docker network destroying its data and Docker image
	cd docker/nginx-php && $(MAKE) clear destroy

laravel-install: ## installs the application pre-defined version with its dependency packages into container
	cd docker/nginx-php && $(MAKE) app-install

laravel-update: ## updates the application dependency packages into container
	cd docker/nginx-php && $(MAKE) app-update

# -------------------------------------------------------------------------------------------------
#  Database Container Service
# -------------------------------------------------------------------------------------------------
.PHONY: database-install database-replace database-backup

database-install: ## installs into container database the init sql file from resources/database
	sudo docker exec -i $(DB_CAAS) sh -c 'exec mysql $(DB_NAME) -uroot -p"$(DB_ROOT)"' < $(DB_BACKUP_PATH)/$(DB_BACKUP_NAME)-init.sql
	echo ${C_YEL}"DATABASE"${C_END}" has been installed."

database-replace: ## replaces container database with the latest sql backup file from resources/database
	sudo docker exec -i $(DB_CAAS) sh -c 'exec mysql $(DB_NAME) -uroot -p"$(DB_ROOT)"' < $(DB_BACKUP_PATH)/$(DB_BACKUP_NAME)-backup.sql
	echo ${C_YEL}"DATABASE"${C_END}" has been replaced."

database-backup: ## creates / replace a sql backup file from container database in resources/database
	sudo docker exec $(DB_CAAS) sh -c 'exec mysqldump $(DB_NAME) -uroot -p"$(DB_ROOT)"' > $(DB_BACKUP_PATH)/$(DB_BACKUP_NAME)-backup.sql
	echo ${C_YEL}"DATABASE"${C_END}" backup has been created."

# -------------------------------------------------------------------------------------------------
#  Repository Helper
# -------------------------------------------------------------------------------------------------
repo-flush: ## clears local git repository cache specially to update .gitignore
	git rm -rf --cached .
	git add .
	git commit -m "fix: cache cleared for untracked files"

repo-commit: ## echoes commit helper
	echo "git add . && git commit -m \"maint: ... \" && git push -u origin main"
