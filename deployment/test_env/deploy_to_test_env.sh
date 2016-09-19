#!/usr/bin/env bash

../shared/init_env.sh

export DOCKER_HOST="tcp://elb-test-env-swarm-683069932.us-east-1.elb.amazonaws.com:2376"

../shared/pull_images.sh

../shared/restart.sh