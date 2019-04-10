#!/usr/bin/env bash

: "${KEEP_OR_WIPE:?Need to set KEEP_OR_WIPE}"

WIPE_MSG="Will WIPE data!"
KEEP_MSG="Will keep data."
USE_ENV_MSG="Will use whatever is in the env file."

# Bring it down
/usr/local/bin/docker-compose kill
/usr/local/bin/docker-compose down -v
docker rm $(docker ps -aq)
docker rmi $(docker images -aq)

# get spring_profiles_active from env file
PROFILES=`cat .env settings.env | grep -v '^#' | grep spring_profiles_active | sed -e s/.*=//`
: "${PROFILES:?Need to set spring_profiles_active - could not parse}"

# based on KEEP_OR_WIPE we do/don't change the profiles set
echo "Profiles read from env: $PROFILES"
if [ "$KEEP_OR_WIPE" == "wipe" ]; then
  echo "$WIPE_MSG"
  PROFILES="${PROFILES//production}"
elif [ "$KEEP_OR_WIPE" == "keep" ]; then
  echo "$KEEP_MSG"
  PROFILES="${PROFILES//demo-data}"
  PROFILES="${PROFILES//performance-data}"
  if [[ $PROFILES != *"production"* ]]; then
    PROFILES="$PROFILES,production"
  fi
else
  echo "$USE_ENV_MSG"
fi
PROFILES=`echo $PROFILES | sed -e s/^,*//` # strip any leading commas
export spring_profiles_active=$PROFILES
echo "Profiles to use: $spring_profiles_active"

# start it up
/usr/local/bin/docker-compose up --build --force-recreate -d
