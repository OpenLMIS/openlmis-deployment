#!/usr/bin/env bash

WIPE_MSG="Will WIPE data!"
KEEP_MSG="Will keep data."
USE_ENV_MSG="Will use whatever is in the env file."

/usr/local/bin/docker-compose kill
/usr/local/bin/docker-compose down -v

if [ "$KEEP_OR_WIPE" == "wipe" ]; then
  echo "$WIPE_MSG"
  export spring_profiles_active="demo-data,refresh-db"
  /usr/local/bin/docker-compose up --build --force-recreate -d
elif [ "$KEEP_OR_WIPE" == "keep" ]; then
  echo "$KEEP_MSG"
  export spring_profiles_active="production,demo-data"
  /usr/local/bin/docker-compose up --build --force-recreate -d
else
  echo "$USE_ENV_MSG"
  /usr/local/bin/docker-compose up --build --force-recreate -d
fi
