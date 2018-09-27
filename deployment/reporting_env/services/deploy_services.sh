#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://nifi-registry.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/credentials"
export DOCKER_COMPOSE_BIN=/usr/local/bin/docker-compose
export REPORTING_DIR_NAME=reporting

export SUPERSET_ENABLE_SSL=true
export SUPERSET_SSL_CERT_CHAIN=reporting-uat/ssl-fullchain-reporting.uat.openlmis.org.pem
export SUPERSET_SSL_KEY=reporting-uat/ssl-privkey-reporting.uat.openlmis.org.pem
export SUPERSET_SSL_CERT=reporting-uat/ssl-fullchain-reporting.uat.openlmis.org.pem
export SUPERSET_DOMAIN_NAME=superset.uat.openlmis.org
export NIFI_ENABLE_SSL=true
export NIFI_SSL_CERT_CHAIN=reporting-uat/ssl-fullchain-reporting.uat.openlmis.org.pem
export NIFI_SSL_KEY=reporting-uat/ssl-privkey-reporting.uat.openlmis.org.pem
export NIFI_SSL_CERT=reporting-uat/ssl-fullchain-reporting.uat.openlmis.org.pem
export NIFI_DOMAIN_NAME=nifi.uat.openlmis.org

reportingRepo=$1

cp -r "$credentials" "$DOCKER_CERT_PATH"
cp -r "$reporting_ssl" "$reportingRepo/$REPORTING_DIR_NAME/config/services/nginx/tls/reporting-uat"
cd "$reportingRepo/$REPORTING_DIR_NAME"
$DOCKER_COMPOSE_BIN kill
$DOCKER_COMPOSE_BIN down -v
$DOCKER_COMPOSE_BIN up --build --force-recreate -d
