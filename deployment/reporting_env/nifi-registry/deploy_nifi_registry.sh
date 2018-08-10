#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="nifi-registry.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"

../shared/init_env_gh.sh
