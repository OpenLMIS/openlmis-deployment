#!/usr/bin/env bash

WIPE_MSG="Will WIPE data!"
KEEP_MSG="Will keep data."

/usr/local/bin/docker-compose down

if [ "$KEEP_OR_WIPE" == "wipe" ]; then
  echo "$WIPE_MSG"
  unset spring_profiles_active
  /usr/local/bin/docker-compose up --build --force-recreate -d
else
  echo "$KEEP_MSG";
  export spring_profiles_active="production"
  /usr/local/bin/docker-compose up --build --force-recreate -d
fi
