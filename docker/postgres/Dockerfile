FROM pgvector/pgvector:pg17-trixie

ARG AGE_REF=PG17/v1.7.0-rc0

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       ca-certificates \
       git \
       bison \
       flex \
       postgresql-server-dev-17 \
    && git clone --depth 1 --branch "${AGE_REF}" https://github.com/apache/age.git /tmp/age \
    && cd /tmp/age \
    && make PG_CONFIG=/usr/lib/postgresql/17/bin/pg_config install \
    && cd / \
    && rm -rf /tmp/age \
    && apt-get purge -y --auto-remove build-essential git bison flex postgresql-server-dev-17 \
    && rm -rf /var/lib/apt/lists/*

COPY docker/postgres/init/ /docker-entrypoint-initdb.d/

RUN chmod 644 /docker-entrypoint-initdb.d/*.sql || true

USER postgres
