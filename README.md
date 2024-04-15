<div style="width:100%;float:left;clear:both;margin-bottom:50px;">
    <a href="https://github.com/pabloripoll?tab=repositories">
        <img style="width:150px;float:left;" src="https://pabloripoll.com/files/logo-light-100x300.png"/>
    </a>
</div>

<div style="width:100%;float:left;clear:both;margin-bottom:50px;">
    <a href="resources/doc/laravel-11-screenshot.png">
        <img style="width:100%;float:left;" src="resources/doc/laravel-11-screenshot.png"/>
    </a>
</div>

# Docker Laravel 11 with PHP FPM 8+

The objective of this repository is having a CaaS [Containers as a Service](https://www.ibm.com/topics/containers-as-a-service) to provide a start up application with the basic enviroment features to deploy a php service running with Nginx and PHP-FPM in a container for [Laravel](https://laravel.com/) and another container with a MySQL database to follow the best practices on an easy scenario to understand and modify on development requirements.

The connection between container is as [Host Network](https://docs.docker.com/network/drivers/host/) on `eth0`, thus both containers do not share networking or bridge configuration.

As client end user both services can be accessed through `localhost:${PORT}` but the connection between containers is through the `${HOSTNAME}:${PORT}`.

### Laravel Docker Container Service

- [Laravel 11](https://laravel.com/docs/11.x/releases)

- [PHP-FPM 8.3](https://www.php.net/releases/8.3/en.php)

- [Nginx 1.24](https://nginx.org/)

- [Alpine Linux 3.19](https://www.alpinelinux.org/)

### Database Service

This project does not include a database service for it is intended to connect to a database instance like in a cloud database environment or similar.

To emulate a SQL database service it can be used the following [MariaDB 10.11](https://mariadb.com/kb/en/changes-improvements-in-mariadb-1011/) repository:
- [https://github.com/pabloripoll/docker-mariadb-10.11](https://github.com/pabloripoll/docker-mariadb-10.11)

### Project objetives with Docker

* Built on the lightweight and secure Alpine 3.19 [2024 release](https://www.alpinelinux.org/posts/Alpine-3.19.1-released.html) Linux distribution
* Multi-platform, supporting AMD4, ARMv6, ARMv7, ARM64
* Very small Docker image size (+/-40MB)
* Uses PHP 8.3 as default for the best performance, low CPU usage & memory footprint, but also can be downgraded till PHP 8.0
* Optimized for 100 concurrent users
* Optimized to only use resources when there's traffic (by using PHP-FPM's `on-demand` process manager)
* The services Nginx, PHP-FPM and supervisord run under a project-privileged user to make it more secure
* The logs of all the services are redirected to the output of the Docker container (visible with `docker logs -f <container name>`)
* Follows the KISS principle (Keep It Simple, Stupid) to make it easy to understand and adjust the image to your needs
* Services independency to connect the application to other database allocation

#### PHP config

To use a different PHP 8 version the following [Dockerfile](docker/nginx-php/docker/Dockerfile) arguments and variable has to be modified:
```Dockerfile
ARG PHP_VERSION=8.3
ARG PHP_ALPINE=83
...
ENV PHP_V="php83"
```

Also, it has to be informed to [Supervisor Config](docker/nginx-php/docker/config/supervisord.conf) the PHP-FPM version to run.
```bash
...
[program:php-fpm]
command=php-fpm83 -F
...
```

## Dockerfile insight
```
# Install main packages and remove default server definition
RUN apk add --no-cache \
  curl \
  wget \
  nginx \
  curl \
  zip \
  bash \
  vim \
  git \
  supervisor

RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
        libzip-dev \
        freetype-dev \
        icu-dev \
        libmcrypt-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libxslt-dev \
        patch \
        openssh-client

# Install PHP and its extensions packages and remove default server definition
ENV PHP_V="php83"

RUN apk add --no-cache \
  ${PHP_V} \
  ${PHP_V}-cli \
  ${PHP_V}-ctype \
  ${PHP_V}-curl \
  ${PHP_V}-dom \
  ${PHP_V}-fileinfo \
  ${PHP_V}-fpm \
  ${PHP_V}-gd \
  ${PHP_V}-intl \
  ${PHP_V}-mbstring \
  ${PHP_V}-opcache \
  ${PHP_V}-openssl \
  ${PHP_V}-phar \
  ${PHP_V}-session \
  ${PHP_V}-tokenizer \
  ${PHP_V}-soap \
  ${PHP_V}-xml \
  ${PHP_V}-xmlreader \
  ${PHP_V}-xmlwriter \
  ${PHP_V}-simplexml \
  ${PHP_V}-zip \
  # Databases
  ${PHP_V}-pdo \
  ${PHP_V}-pdo_sqlite \
  ${PHP_V}-sqlite3 \
  ${PHP_V}-pdo_mysql \
  ${PHP_V}-mysqlnd \
  ${PHP_V}-mysqli \
  ${PHP_V}-pdo_pgsql \
  ${PHP_V}-pgsql \
  ${PHP_V}-mongodb \
  ${PHP_V}-redis

# PHP Docker
RUN docker-php-ext-install pdo pdo_mysql gd

# PHP PECL extensions
RUN apk add \
  ${PHP_V}-pecl-amqp \
  ${PHP_V}-pecl-xdebug
```

## Directories Structure

Directories and main files on a tree architecture description. Main `/docker` directory has `/nginx-php` directory separated in case of needing to be included other container service directory with its specific contents
```
.
│
├── docker
│   │
│   ├── nginx-php
│   │   ├── docker
│   │   │   ├── config
│   │   │   ├── .env
│   │   │   ├── docker-compose.yml
│   │   │   └── Dockerfile
│   │   │
│   │   └── Makefile
│   │
│   └── (other...)
│
├── resources
│   │
│   ├── database
│   │   ├── laravel-init.sql
│   │   └── laravel-backup.sql
│   │
│   ├── doc
│   │   └── (any documentary file...)
│   │
│   └── laravel
│       └── (any file or directory required for start-up or re-building the app...)
│
├── laravel
│   └── (application...)
│
├── .env
├── .env.example
└── Makefile
```

## Automation with Makefile

Makefiles are often used to automate the process of building and compiling software on Unix-based systems as Linux and macOS.

*On Windows - I recommend to use Makefile: \
https://stackoverflow.com/questions/2532234/how-to-run-a-makefile-in-windows*

Makefile recipies
```bash
$ make help
usage: make [target]

targets:
Makefile  help                    shows this Makefile help message
Makefile  hostname                shows local machine ip
Makefile  fix-permission          sets project directory permission
Makefile  host-check              shows this project ports availability on local machine
Makefile  laravel-ssh             enters the application container shell
Makefile  laravel-set             sets the application PHP enviroment file to build the container
Makefile  laravel-create          creates the application PHP container from Docker image
Makefile  laravel-start           starts the application PHP container running
Makefile  laravel-stop            stops the application PHP container but data will not be destroyed
Makefile  laravel-destroy         removes the application PHP from Docker network destroying its data and Docker image
Makefile  laravel-install         installs the application pre-defined version with its dependency packages into container
Makefile  laravel-update          updates the application dependency packages into container
Makefile  database-install        installs into container database the init sql file from resources/database
Makefile  database-replace        replaces container database with the latest sql backup file from resources/database
Makefile  database-backup         creates / replace a sql backup file from container database in resources/database
Makefile  repo-flush              clears local git repository cache specially to update .gitignore
Makefile  repo-commit             echoes commit helper commands
```

## Service Configuration

Create a [DOTENV](.env) file from [.env.example](.env.example) and setup according to your project requirement the following variables
```
# REMOVE COMMENTS WHEN COPY THIS FILE

# Leave it empty if no need for sudo user to execute docker commands
DOCKER_USER=sudo

# Container data for docker-compose.yml
PROJECT_TITLE="LARAVEL"         # <- this name will be prompt for Makefile recipes
PROJECT_ABBR="lara-nginx-php"   # <- part of the service image tag - useful if similar services are running

# Laravel container
PROJECT_HOST="127.0.0.1"                    # <- for this project is not necessary
PROJECT_PORT="8888"                         # <- port access container service on local machine
PROJECT_CAAS="laravel-app"                  # <- container as a service name to build service
PROJECT_PATH="../../../laravel"             # <- path where application is binded from container to local

# Database service container
DB_CAAS="mariadb"                           # <- name of the database docker container service to access by ssh
DB_NAME="mariadb"                           # <- name of the database to copy or replace
DB_ROOT="7c4a8d09ca3762af61e59520943d"      # <- database root password
DB_BACKUP_NAME="laravel"                    # <- the name of the database backup or copy file
DB_BACKUP_PATH="resources/database"         # <- path where database backup or copy resides
```

*(Database service container is explained [below](https://github.com/pabloripoll/docker-symfony-6-php-fpm-8?tab=readme-ov-file#custom-database-service-usage))*

Exacute the following command to create the [docker/.env](docker/.env) file, required for building the container
```bash
$ make laravel-set
LARAVEL docker-compose.yml .env file has been set.
```

Checkout port availability from the set enviroment
```bash
$ make host-check

Checking configuration for LARAVEL container:
LARAVEL > port:8888 is free to use.
```

Checkout local machine IP to set connection between container services using the following makefile recipe if required
```bash
$ make hostname

192.168.1.41
```

## Create the application container service

```bash
$ make laravel-create

LARAVEL docker-compose.yml .env file has been set.

[+] Building 54.3s (26/26) FINISHED                                       docker:default
=> [nginx-php internal] load build definition from Dockerfile                       0.0s
 => => transferring dockerfile: 2.78kB                                              0.0s
 => [nginx-php internal] load metadata for docker.io/library/composer:latest        1.5s
 => [nginx-php internal] load metadata for docker.io/library/php:8.3-fpm-alpine     1.5s
 => [nginx-php internal] load .dockerignore                                         0.0s
 => => transferring context: 108B                                                   0.0s
 => [nginx-php internal] load build context                                         0.0s
 => => transferring context: 8.30kB                                                 0.0s
 => [nginx-php] FROM docker.io/library/composer:latest@sha256:63c0f08ca41370...
...
 => [nginx-php] exporting to image                                                  1.0s
 => => exporting layers                                                             1.0s
 => => writing image sha256:3c99f91a63edd857a0eaa13503c00d500fad57cf5e29ce1d...     0.0s
 => => naming to docker.io/library/laravel-app:laravel-nginx-php                    0.0s
[+] Running 1/2
 ⠴ Network laravel-app_default  Created                                             0.4s
 ✔ Container laravel-app        Started                                             0.3s
[+] Running 1/0
 ✔ Container laravel-app        Running
```

## Project Service

If the container is built with the pre-installed application content, by browsing to localhost with the selected port configured [http://localhost:8888/](http://localhost:8888/) will display the successfully installation welcome page.

The pre-installed application could require to update its dependencies. The following Makefile recipe will update dependencies set on `composer.json` file
```bash
$ make laravel-update
```

If it is needed to build the container with other type of application configuration from base, there is a Makefile recipe to set at [docker/Makefile](docker/Makefile) all the commands needed for its installation.
```bash
$ make laravel-install
```

## Container Information

Docker image size
```bash
$ sudo docker images
REPOSITORY   TAG           IMAGE ID       CREATED         SIZE
laravel-app  lara...       373f6967199b   5 minutes ago   251MB
```

Stats regarding the amount of disk space used by the container
```bash
$ sudo docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          1         1         251.4MB   0B (0%)
Containers      1         1         4B        0B (0%)
Local Volumes   1         0         117.9MB   117.9MB (100%)
Build Cache     39        0         10.56kB   10.56kB
```

## Stopping the Container Service

Using the following Makefile recipe stops application from running, keeping database persistance and application files binded without any loss
```bash
$ make laravel-stop
[+] Stopping 1/1
 ✔ Container laravel-app  Stopped                                                    0.5s
```

## Removing the Container Image

To remove application container from Docker network use the following Makefile recipe *(Docker prune commands still needed to be applied manually)*
```bash
$ make laravel-destroy

[+] Removing 1/0
 ✔ Container laravel-app  Removed                                                     0.0s
[+] Running 1/1
 ✔ Network laravel-app_default  Removed                                               0.4s
Untagged: laravel-app:laravel-nginx-php
Deleted: sha256:3c99f91a63edd857a0eaa13503c00d500fad57cf5e29ce1da3210765259c35b1
```

Information on pruning Docker system cache
```bash
$ sudo docker system prune

...
Total reclaimed space: 168.4MB
```

Information on pruning Docker volume cache
```bash
$ sudo docker volume prune

...
Total reclaimed space: 0MB
```

## Laravel service check

There are two PHP files on [resources/laravel](resources/laravel) with same structure as application to replace or add a predifined example to test the service.

It can be used an API platform service *(Postman, Firefox RESTClient, etc..)* or just browsing the following endpoints to check connection with Laravel.

Check-out a basic service check
```
GET: http://localhost:8888/api/v1/health

{
    "status": true
}
```

Check connection to database through this endpoint. If conenction params are not set already or does not exist, endpoint response will be as follow
```
GET: http://localhost:8888/api/v1/health/db

{
    "status": false,
    "message": "Connect to database failed - Check connection params.",
    "error": {
        "errorInfo": [
            "HY000",
            2002,
            "Host is unreachable"
        ]
    }
}
```

When a proper connection is set, endpoint will response as follow
```
GET: http://localhost:8888/api/v1/health/db

{
    "status": true
}
```

## Custom database service usage

In case of using the repository [https://github.com/pabloripoll/docker-mariadb-10.11](https://github.com/pabloripoll/docker-mariadb-10.11) as database service, complete the application mysql database connection params in [laravel/.env](laravel/.env) file.

Use local hostname IP `$ make hostname` to set `DB_HOST` variable
```
DB_CONNECTION=mysql
DB_HOST=192.168.1.41
DB_PORT=8880
DB_DATABASE=mariadb
DB_USERNAME=mariadb
DB_PASSWORD=123456
```

Migration has to be performed inside container. Access container with the following recipe:
```bash
$ make laravel-ssh
```

### Dumping Database

Every time the containers are built up and running it will be like start from a fresh installation.

You can continue using this repository with the pre-set database executing the command `$ make database-install`

Follow the next recommendations to keep development stages clear and safe.

*On first installation* once the app service is running with basic tables set, I suggest to make a initialization database backup manually, saving as [resources/database/laravel-backup.sql](resources/database/laravel-backup.sql) but renaming as [resources/database/laravel-init.sql](resources/database/laravel-init.sql) to have that init database for any Docker compose rebuild / restart on next time.

**The following three commands are very useful for *Continue Development*.**

### DB Backup

When the project is already in an advanced development stage, making a backup is recommended to keep lastest database registers.
```bash
$ make database-backup

DATABASE backup has been created.
```

### DB Install

If it is needed to restart the project from base installation step, you can use the init database .sql file to restart at that point in time. Although is not common to use, helps to check and test installation health.
```bash
$ make database-install

DATABASE has been installed.
```

This repository comes with an initialized .sql with a main database user. See [.env.example](.env.example)

### DB Replace

Replace the database set on container with the latest .sql backup into current development stage.
```bash
$ make database-replace

DATABASE has been replaced.
```

#### Notes

- Notice that both files in [resources/database/](resources/database/) have the name that has been set on the main `.env` file to automate processes.

- Remember that on any change in the main `.env` file will be required to execute the following Makefile recipe
```bash
$ make laravel-set

LARAVEL docker-compose.yml .env file has been set.
```

## Connection between containers

#### On Windows systems

This project has not been tested on Windows OS neither I can use it to test it. So, I cannot bring much support on it.

Anyway, using this repository you will needed to find out your PC IP by login as an `administrator user` to set connection between containers.

```bash
C:\WINDOWS\system32>ipconfig /all

Windows IP Configuration

 Host Name . . . . . . . . . . . . : 191.128.1.41
 Primary Dns Suffix. . . . . . . . : paul.ad.cmu.edu
 Node Type . . . . . . . . . . . . : Peer-Peer
 IP Routing Enabled. . . . . . . . : No
 WINS Proxy Enabled. . . . . . . . : No
 DNS Suffix Search List. . . . . . : scs.ad.cs.cmu.edu
```

Take the first ip listed. Wordpress container will connect with database container using that IP.

#### On Unix based systems

Find out your IP on UNIX systems and take the first IP listed
```bash
$ hostname -I

191.128.1.41 172.17.0.1 172.20.0.1 172.21.0.1
```
