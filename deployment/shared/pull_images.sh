#!/usr/bin/env bash

docker pull openlmis/rsyslog:1
docker pull openlmis/postgres:9.6
docker pull openlmis/nginx:1
docker pull gliderlabs/consul-server

# $1 is the parameter passed in
/usr/local/bin/docker-compose pull $1

