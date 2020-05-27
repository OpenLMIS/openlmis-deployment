#!/usr/bin/env bash

set -e
export DOCKER_TLS_VERIFY="1"
export COMPOSE_TLS_VERSION=TLSv1_2
export DOCKER_HOST="tcp://nifi-registry.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"

../../shared/init_env_gh.sh

/usr/local/bin/docker-compose kill
/usr/local/bin/docker-compose down -v
/usr/local/bin/docker-compose up --build --force-recreate -d
