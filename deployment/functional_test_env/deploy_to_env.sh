#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://functional-test.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"

../shared/init_env_gh.sh

if $START_EC2_INSTANCE; then
  cp .deployment-config/functional-test.env settings.env
  docker pull openlmis/start-instance
  /usr/bin/docker run --rm --env-file settings.env openlmis/start-instance
fi

../shared/pull_images.sh $1

../shared/restart.sh $1
