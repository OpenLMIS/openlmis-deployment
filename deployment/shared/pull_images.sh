#!/usr/bin/env bash

docker pull openlmis/rsyslog
docker pull openlmis/postgres:9.4
docker pull openlmis/nginx
docker pull gliderlabs/consul-server

# $1 is the parameter passed in
/usr/local/bin/docker-compose pull $1

