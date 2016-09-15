#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://elb-test-env-swarm-683069932.us-east-1.elb.amazonaws.com:2376"

curl -LO https://raw.githubusercontent.com/OpenLMIS/openlmis-config/master/.env

docker pull $1

/usr/local/bin/docker-compose down

/usr/local/bin/docker-compose up -d