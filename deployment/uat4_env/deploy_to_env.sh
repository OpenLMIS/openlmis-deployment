#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://uat4.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"

../shared/init_env_gh.sh

if [ ! -z "$ENV_RESTORE_SNAPSHOT" ]; then
  export KEEP_OR_WIPE="use_env"
  cp .deployment-config/$ENV_RESTORE_SNAPSHOT settings.env
  docker pull openlmis/restore-snapshot
  docker pull openlmis/obscure-data
  /usr/bin/docker run --rm --env-file settings.env openlmis/restore-snapshot
  sleep 600
else
  cp .deployment-config/uat4.env settings.env
fi

../shared/pull_images.sh $1

../shared/restart.sh $1
