#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://${SERVER_URL}:${DOCKER_PORT}"
export DOCKER_CERT_PATH="${PWD}/credentials"

./init_env_gh.sh

./pull_images.sh $1

./restart.sh $1
