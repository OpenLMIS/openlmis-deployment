#!/usr/bin/env bash

WIPE_MSG="Will WIPE data!"
KEEP_MSG="Will keep data."

if [ ! -z "$1" ];
  then
  if [ "$KEEP_OR_WIPE" == "wipe" ];
    #when run locally, and the env var is not present, else branch will run, thus to keep data
    then
    echo "$WIPE_MSG"
    /usr/local/bin/docker-compose rm -fv $1
  else
    echo "$KEEP_MSG";
    /usr/local/bin/docker-compose stop $1
    /usr/local/bin/docker-compose up -d $1
  fi
else
  if [ "$KEEP_OR_WIPE" == "wipe" ];
    #when run locally, and the env var is not present, else branch will run, thus to keep data
    then
    echo "$WIPE_MSG"
    /usr/local/bin/docker-compose down -v
  else
    echo "$KEEP_MSG";
    /usr/local/bin/docker-compose down
  fi
  /usr/local/bin/docker-compose up -d
fi

