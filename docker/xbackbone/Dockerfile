FROM webdevops/php-nginx:8.4-alpine

ARG XBACKBONE_VERSION=3.8.1

LABEL org.opencontainers.image.title="XBackBone Docker" \
      org.opencontainers.image.description="XBackBone packaged on top of webdevops/php-nginx" \
      org.opencontainers.image.source="https://github.com/davidjameshowell/XBackBone-docker-x64" \
      org.opencontainers.image.licenses="MIT"

ENV APP_NAME=XBackBone \
    URL=http://127.0.0.1

COPY nginx.conf /opt/docker/etc/nginx/vhost.common.d/11-xbackbone.conf
COPY configure.sh /opt/docker/provision/entrypoint.d/01-app.sh

RUN chmod 0755 /opt/docker/provision/entrypoint.d/01-app.sh

WORKDIR /app
USER application

RUN set -eux; \
    wget "https://github.com/SergiX44/XBackBone/releases/download/${XBACKBONE_VERSION}/release-v${XBACKBONE_VERSION}.zip" -O /tmp/xbackbone.zip; \
    unzip /tmp/xbackbone.zip -d /app; \
    rm /tmp/xbackbone.zip; \
    mkdir -p /app/config

VOLUME ["/app/storage", "/app/resources/database", "/app/logs", "/app/config"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD wget -q --spider http://127.0.0.1/login || exit 1

# The base image entrypoint starts as root and drops privileges after setup.
USER root