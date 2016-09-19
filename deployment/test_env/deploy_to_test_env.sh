#!/usr/bin/env bash

./import.sh ~/host1.zip

eval $(/usr/local/bin/docker-machine env host1)

/usr/local/bin/docker-machine/docker-machine scp ./nginx.tmpl host1:~/nginx.tmpl

curl -LO https://raw.githubusercontent.com/OpenLMIS/openlmis-config/master/.env

docker pull openlmis/rsyslog
docker pull openlmis/postgres
docker pull gliderlabs/consul-server
docker pull gliderlabs/registrator
docker pull jwilder/nginx-proxy

docker pull $1

/usr/local/bin/docker-compose down

/usr/local/bin/docker-compose up -d