ARG UPTRACK_SOURCE=nginx:mainline-alpine-otel
ARG GOENVTEMPLATOR_VERSION=2025.2.14
FROM docker.io/framjet/goenvtemplator:${GOENVTEMPLATOR_VERSION} AS goenvtemplator
FROM docker.io/framjet/alpine:latest AS alpine
FROM ${UPTRACK_SOURCE} AS builder

LABEL org.opencontainers.image.authors="Aurimas Niekis <aurimas@niekis.lt>"

COPY --from=goenvtemplator --chown=root /usr/local/bin/goenvtemplator /usr/local/bin/goenvtemplator

# Copy wait4x binary from alpine image
COPY --from=alpine --chown=root /usr/local/bin/wait4x /usr/local/bin/wait4x

# Copy entrypoints from alpine base image
COPY --chown=root --from=alpine /docker-entrypoint.d/* /docker-entrypoint.d/
COPY --chown=root --from=alpine /docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=root --from=alpine /docker-entrypoint.functions /docker-entrypoint.functions

COPY --chown=root nginx.conf.tmpl /etc/nginx/nginx.conf.tmpl
COPY --chown=root docker-entrypoint.d/* /docker-entrypoint.d


# Configure entrypoint
ENV DOCKER_ENTRYPOINT_COMMANDS="nginx"
