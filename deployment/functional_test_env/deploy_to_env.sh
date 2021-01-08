#!/usr/bin/env bash

docker pull openlmis/start-instance

if $START_EC2_INSTANCE; then
  echo "Starting EC2 instance for functional test server"
  /usr/bin/docker run --rm --env-file settings.env openlmis/start-instance
fi

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://functional-test.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"

../shared/init_env_gh.sh

if [ ! -z "$ENV_RESTORE_SNAPSHOT" ]; then
  cp .deployment-config/$ENV_RESTORE_SNAPSHOT settings.env
  docker pull openlmis/restore-snapshot
  docker pull openlmis/obscure-data
  /usr/bin/docker run --rm --env-file settings.env openlmis/restore-snapshot
  sleep 300
  /usr/bin/docker run --rm --env-file settings.env openlmis/obscure-data
fi

../shared/pull_images.sh $1

../shared/restart.sh $1
