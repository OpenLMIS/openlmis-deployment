#!/usr/bin/env bash
set -e

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://casper-elmis.a.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"

cp -r $credentials ./credentials
cd ./build

/usr/local/bin/docker-compose down -v
/usr/local/bin/docker-compose -f docker-compose.builder.yml build image
docker network inspect casper_elmis_pipeline_bridge &>/dev/null || docker network create --driver bridge casper_elmis_pipeline_bridge
/usr/local/bin/docker-compose up -d
