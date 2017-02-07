#!/usr/bin/env bash

WIPE_MSG="Will WIPE data!"
KEEP_MSG="Will keep data."

if [ "$KEEP_OR_WIPE" == "wipe" ];
  then
  echo "$WIPE_MSG"
  /usr/local/bin/docker-compose down -v
else
  echo "$KEEP_MSG";
  /usr/local/bin/docker-compose down
fi
/usr/local/bin/docker-compose up -d
