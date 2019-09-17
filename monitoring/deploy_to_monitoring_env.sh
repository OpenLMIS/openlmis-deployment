#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="grafana.a.openlmis.org:2376"

/usr/local/bin/docker-compose kill
if [ "$KEEP_OR_WIPE" == "WIPE" ]; then
    /usr/bin/docker volume rm influxdb-volume
fi
/usr/local/bin/docker-compose down -v
/usr/bin/docker volume create influxdb-volume
/usr/local/bin/docker-compose pull
/usr/local/bin/docker-compose up --build --force-recreate -d
