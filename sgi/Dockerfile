# Startup Grants India build of Decision Engine (routing only).
# Build context: repository root.
#
# BASE_IMAGE is Juspay's published image for the upstream release this branch
# is pinned to. To run code compiled from THIS fork instead (e.g. after a
# patch), build Dockerfile.postgres first and pass its image as BASE_IMAGE.
ARG BASE_IMAGE=ghcr.io/juspay/decision-engine/postgres:v1.4.35
FROM ${BASE_IMAGE}

RUN apt-get update \
    && apt-get install -y --no-install-recommends postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# The binary reads ./config/development.toml relative to WORKDIR (/local).
COPY sgi/config.toml /local/config/development.toml
COPY migrations_pg /local/migrations_pg
COPY sgi/start.sh /local/start.sh
RUN chmod +x /local/start.sh

ENV PORT=8080
EXPOSE 8080
CMD ["/local/start.sh"]
