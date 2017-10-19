#!/usr/bin/env bash

: "${KEEP_OR_WIPE:?Need to set KEEP_OR_WIPE}"

WIPE_MSG="Will WIPE data!"
KEEP_MSG="Will keep data."
USE_ENV_MSG="Will use whatever is in the env file."

# Bring it down
/usr/local/bin/docker-compose kill
/usr/local/bin/docker-compose down -v

# source the env file as we want to know the spring profiles
source .env
: "${spring_profiles_active:?Need to set spring_profiles_active}"

# based on KEEP_OR_WIPE we do/don't change the profiles set
PROFILES=$spring_profiles_active
echo "Profiles read from env: $PROFILES"
if [ "$KEEP_OR_WIPE" == "wipe" ]; then
  echo "$WIPE_MSG"
  PROFILES="${PROFILES//production}"
elif [ "$KEEP_OR_WIPE" == "keep" ]; then
  echo "$KEEP_MSG"
  if [[ $PROFILES != *"production"* ]]; then
    PROFILES="$PROFILES,production"
  fi
else
  echo "$USE_ENV_MSG"
fi
export spring_profiles_active=$PROFILES
echo "Profiles to use: $spring_profiles_active"

# start it up
/usr/local/bin/docker-compose up --build --force-recreate -d
