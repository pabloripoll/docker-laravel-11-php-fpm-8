ARG ALPINE_VERSION=3.20.0
ARG NODE_VERSION=22.2.0

FROM node:${NODE_VERSION}-alpine AS node
FROM alpine:${ALPINE_VERSION}

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
  nano \
  supervisor

# Configure nginx - http
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure nginx - default server
COPY config/conf.d /etc/nginx/conf.d/

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure NodeJS
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

RUN node -v

RUN npm install -g yarn --force
RUN npm -v
RUN yarn -v

# Create project root
RUN mkdir -p /var/www/htdocs

WORKDIR /var/www/htdocs

# Container ports
EXPOSE 80 443 3000

# Services on built or start
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
