#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://casper.a.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"

../shared/init_env_gh.sh

docker pull openlmis/demo-data:casper
/usr/bin/docker run --rm --env-file settings.env openlmis/demo-data:casper

../shared/pull_images.sh $1

../shared/restart.sh $1
