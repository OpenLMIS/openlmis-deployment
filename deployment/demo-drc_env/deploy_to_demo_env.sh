#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://demo-drc-env-elb-1549601289.us-east-1.elb.amazonaws.com:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"

../shared/init_env_gh.sh

../shared/pull_images.sh $1

../shared/restart.sh $1
