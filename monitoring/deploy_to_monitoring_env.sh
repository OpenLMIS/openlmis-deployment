#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="grafana.a.openlmis.org:2376"
export DOCKER_CERT_PATH="${credentials}"

/usr/local/bin/docker-compose kill
/usr/local/bin/docker-compose down -v
/usr/local/bin/docker-compose pull
/usr/local/bin/docker-compose up --build --force-recreate -d
