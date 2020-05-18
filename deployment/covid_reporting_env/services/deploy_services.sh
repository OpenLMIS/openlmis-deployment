#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export COMPOSE_TLS_VERSION=TLSv1_2
export DOCKER_HOST="tcp://report.covid-ref.openlmis.org:2376"
export DOCKER_COMPOSE_BIN=/usr/local/bin/docker-compose
export REPORTING_DIR_NAME=covid-reporting

distroRepo=$1

docker volume create pgdata

cd "$distro_repo/$REPORTING_DIR_NAME" &&
$DOCKER_COMPOSE_BIN kill &&
$DOCKER_COMPOSE_BIN down -v --remove-orphans &&

$DOCKER_COMPOSE_BIN build &&

$DOCKER_COMPOSE_BIN up -d --scale scalyr=0
