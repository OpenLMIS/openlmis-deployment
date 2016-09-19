#!/usr/bin/env bash

docker pull openlmis/rsyslog
docker pull openlmis/postgres
docker pull gliderlabs/consul-server
docker pull gliderlabs/registrator
docker pull jwilder/nginx-proxy

docker pull $1
#$1 is the parameter passed in