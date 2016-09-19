#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://52.52.3.5:2376"

../shared/init_env.sh

../shared/pull_images.sh $1

../shared/restart.sh