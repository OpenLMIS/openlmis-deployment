#!/usr/bin/env bash

../shared/init_env.sh

export DOCKER_HOST="tcp://52.52.3.5:2376"

../shared/pull_images.sh

../shared/restart.sh