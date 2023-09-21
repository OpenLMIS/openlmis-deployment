#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://uat.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/.deployment-config/uat-certs"

../shared/init_env_gh.sh

../shared/pull_images.sh $1

../shared/restart.sh $1
