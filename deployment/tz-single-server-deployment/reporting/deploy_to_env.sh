#!/usr/bin/env bash

set -xe

: "${KEEP_OR_WIPE:=keep}"

docker compose pull

## stop everything
if [ "wipe" = $KEEP_OR_WIPE ] ;
then
    echo "KEEP_OR_WIPE set to wipe"
    docker compose down -v
else
    echo "KEEP_OR_WIPE set to keep"
    docker compose down
    
    # remove the config volume so it can be recreated`
    docker inspect olmis-report_config-volume || configVolExists=0
    if [ "$configVolExists" != 0 ]; 
    then
        docker volume rm olmis-report_config-volume
    fi
fi

# start it back up
docker compose up --build --force-recreate -d
