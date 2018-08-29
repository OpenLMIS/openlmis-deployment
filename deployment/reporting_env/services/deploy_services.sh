#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://nifi-registry.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"
export DOCKER_COMPOSE_BIN=/usr/local/bin/docker-compose
export REPORTING_DIR_NAME=reporting

reportingRepo=$1

cp -r "$credentials" "$DOCKER_CERT_PATH"
cd "$reportingRepo/$REPORTING_DIR_NAME"
$DOCKER_COMPOSE_BIN kill
$DOCKER_COMPOSE_BIN down -v
$DOCKER_COMPOSE_BIN up --build --force-recreate -d
