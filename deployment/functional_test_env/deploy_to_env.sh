#!/usr/bin/env bash

docker pull openlmis/start-instance

if $START_EC2_INSTANCE; then
  echo "Starting EC2 instance for functional test server"
  /usr/bin/docker run --rm --env-file settings.env openlmis/start-instance
fi

export DOCKER_TLS_VERIFY="0"
export DOCKER_HOST="tcp://functional-test.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"

../shared/init_env_gh.sh


../shared/pull_images.sh $1

../shared/restart.sh $1
