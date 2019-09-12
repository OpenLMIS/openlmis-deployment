#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="grafana.a.openlmis.org:2376"

/usr/local/bin/docker-compose kill
if [ "$KEEP_OR_WIPE" == "KEEP" ]; then
    /usr/local/bin/docker-compose down
else
    /usr/local/bin/docker-compose down -v
fi
/usr/local/bin/docker-compose pull
/usr/local/bin/docker-compose up --build --force-recreate -d
