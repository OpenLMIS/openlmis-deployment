#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://nifi-registry.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"

cp -r $credentials ./credentials
/usr/local/bin/docker-compose kill
/usr/local/bin/docker-compose down -v
/usr/local/bin/docker-compose up --build --force-recreate -d
