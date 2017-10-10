#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://perftest-env-elb-2066004734.us-east-1.elb.amazonaws.com:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"

sh ../shared/init_env_gh.sh

../shared/pull_images.sh $1

../shared/restart.sh $1
