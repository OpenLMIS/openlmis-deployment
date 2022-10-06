#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://perftest.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"

../shared/init_env_gh.sh

unzip "${DOCKER_CERT_PATH}/perftest-certs.zip"

if [ ! -z "$ENV_RESTORE_SNAPSHOT" ]; then
  export KEEP_OR_WIPE="use_env"
  cp .deployment-config/$ENV_RESTORE_SNAPSHOT settings.env
  docker pull openlmis/restore-snapshot
  docker pull openlmis/obscure-data
  /usr/bin/docker run --rm --env-file settings.env openlmis/restore-snapshot
  sleep 300
  /usr/bin/docker run --rm --env-file settings.env openlmis/obscure-data
else
  cp .deployment-config/perftest.env settings.env
  docker pull openlmis/demo-data
  /usr/bin/docker run --rm --env-file settings.env openlmis/demo-data
fi

../shared/pull_images.sh $1

../shared/restart.sh $1
