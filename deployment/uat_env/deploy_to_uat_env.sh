#!/usr/bin/env bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://uat.openlmis.org:2376"
export DOCKER_CERT_PATH="${SCRIPT_DIR}/uat-certs"

# Refreshes the instance state by removing all local artifacts (containers, networks, dangling images).
# The database volume must be external to survive the volume cleanup step.
"$SCRIPT_DIR/../shared/restart_or_restore.sh" "uat_env"
