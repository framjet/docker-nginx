ARG UPTRACK_SOURCE=nginx:mainline-alpine-otel
ARG GOENVTEMPLATOR_VERSION=2025.2.14
ARG WAIT4X_VERSION=latest
FROM docker.io/framjet/goenvtemplator:${GOENVTEMPLATOR_VERSION} AS goenvtemplator
FROM docker.io/atkrad/wait4x:${WAIT4X_VERSION} AS wait4x
FROM ${UPTRACK_SOURCE} AS builder

LABEL org.opencontainers.image.authors="Aurimas Niekis <aurimas@niekis.lt>"

COPY --from=goenvtemplator --chown=root /usr/local/bin/goenvtemplator /usr/local/bin/goenvtemplator
COPY --from=wait4x --chown=root /usr/bin/wait4x /usr/local/bin/wait4x

COPY --chown=root nginx.conf.tmpl /etc/nginx/nginx.conf.tmpl
COPY --chown=root docker-entrypoint.d/09-docker-gen-nginx-conf.sh /docker-entrypoint.d
COPY --chown=root docker-entrypoint.d/90-wait-for-x.sh /docker-entrypoint.d
