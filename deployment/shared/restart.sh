#!/usr/bin/env bash

if [ ! -z "$1" ];
  then
  /usr/local/bin/docker-compose stop $1
  /usr/local/bin/docker-compose up -d $1
else
  if [ "$KEEP_OR_WIPE" == "wipe" ];
    #when run locally, and the env var is not present, else branch will run, thus to keep data
    then
    echo "Will WIPE data!"
    /usr/local/bin/docker-compose down -v
  else
    echo "Will keep data";
    /usr/local/bin/docker-compose down
  fi
  /usr/local/bin/docker-compose up -d
fi

