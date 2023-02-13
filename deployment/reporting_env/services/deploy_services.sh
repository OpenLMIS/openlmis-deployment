#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export COMPOSE_TLS_VERSION=TLSv1_2
export DOCKER_HOST="tcp://superset-uat.openlmis.org:2376"
export DOCKER_COMPOSE_BIN=/usr/local/bin/docker-compose
export DOCKER_CERT_PATH="${PWD}/.deployment-config/reporting-uat-certs"
export REPORTING_DIR_NAME=reporting

../../shared/init_env_gh.sh

reportingRepo=$1

cd "$reportingRepo/$REPORTING_DIR_NAME"
$DOCKER_COMPOSE_BIN kill
$DOCKER_COMPOSE_BIN down -v
docker rm $(docker ps -aq)
docker rmi $(docker images -aq)
$DOCKER_COMPOSE_BIN build --no-cache
$DOCKER_COMPOSE_BIN up --force-recreate -d
