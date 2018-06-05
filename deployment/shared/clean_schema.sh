#!/usr/bin/env bash

set -e

# get db settings from env file
DATABASE_URL=`cat settings.env | grep DATABASE_URL | sed -e s/.*=//`
: "${DATABASE_URL:?Need to set DATABASE_URL - could not parse}"
POSTGRES_USER=`cat settings.env | grep POSTGRES_USER | sed -e s/.*=//`
: "${POSTGRES_USER:?Need to set POSTGRES_USER - could not parse}"
POSTGRES_PASSWORD=`cat settings.env | grep POSTGRES_PASSWORD | sed -e s/.*=//`
: "${POSTGRES_PASSWORD:?Need to set POSTGRES_PASSWORD - could not parse}"

# pull apart some of those pieces stuck together in DATABASE_URL
URL=`echo ${DATABASE_URL} | sed -E 's/^jdbc\:(.+)/\1/'` # jdbc:<url> 
: "${URL:?URL not parsed}"

HOST=`echo ${DATABASE_URL} | sed -E 's/^.*\/{2}(.+):.*$/\1/'` # //<host>: 
: "${HOST:?HOST not parsed}"

PORT=`echo ${DATABASE_URL} | sed -E 's/^.*\:([0-9]+)\/.*$/\1/'` # :<port>/
: "${PORT:?Port not parsed}"

DB=`echo ${DATABASE_URL} | sed -E 's/^.*\/(.+)\?*$/\1/'` # /<db>?
: "${DB:?DB not set}"

# pgpassfile makes it easy and safe to login
echo "${HOST}:${PORT}:${DB}:${POSTGRES_USER}:${POSTGRES_PASSWORD}" > pgpassfile
chmod 600 pgpassfile

# hasta la vista, schema
export PGPASSFILE='pgpassfile'
psql "${URL}" -U ${POSTGRES_USER} -c "drop schema if exists ${1} cascade;" 2>&1
