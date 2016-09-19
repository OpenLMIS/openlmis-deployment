#!/usr/bin/env bash

/usr/local/bin/docker-machine scp ./nginx.tmpl host1:~/nginx.tmpl

eval $(/usr/local/bin/docker-machine env host1)

# the above two commands can only run after the cert files are properly located in jenkins
# details of how to do that is described in the provision markdown


curl -LO https://raw.githubusercontent.com/OpenLMIS/openlmis-config/master/.env

docker pull openlmis/rsyslog
docker pull openlmis/postgres
docker pull gliderlabs/consul-server
docker pull gliderlabs/registrator
docker pull jwilder/nginx-proxy

docker pull $1

/usr/local/bin/docker-compose down

/usr/local/bin/docker-compose up -d