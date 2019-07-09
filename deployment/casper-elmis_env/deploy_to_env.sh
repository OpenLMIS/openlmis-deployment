#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://casper-elmis.a.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"

cp -r $credentials ./credentials
cd ./build

/usr/local/bin/docker-compose down -v
/usr/local/bin/docker-compose -f docker-compose.builder.yml build baseimage
/usr/local/bin/docker-compose -f docker-compose.builder.yml build image
/usr/local/bin/docker-compose up -d
