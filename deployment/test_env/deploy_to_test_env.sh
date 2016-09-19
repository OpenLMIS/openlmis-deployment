#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://elb-test-env-swarm-683069932.us-east-1.elb.amazonaws.com:2376"

curl -LO https://raw.githubusercontent.com/OpenLMIS/openlmis-config/master/.env

docker pull openlmis/rsyslog
docker pull openlmis/postgres
docker pull gliderlabs/consul-server
docker pull gliderlabs/registrator
docker pull jwilder/nginx-proxy

docker pull $1

if [ $KEEP_OR_WIPE == "wipe" ];
#when run locally, and the env var is not present, else branch will run, thus to keep data
then
echo "will WIPE data!!"
/usr/local/bin/docker-compose down -v
else
echo "will keep data";
/usr/local/bin/docker-compose down
fi


/usr/local/bin/docker-compose up -d