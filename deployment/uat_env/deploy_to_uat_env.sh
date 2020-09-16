#!/usr/bin/env bash

export DOCKER_TLS_VERIFY=""
export DOCKER_HOST="tcp://uat.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"

../shared/init_env_gh.sh

../shared/pull_images.sh $1

../shared/restart.sh $1
