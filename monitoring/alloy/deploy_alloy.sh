#!/usr/bin/env bash
# Deploy the Alloy agent to an environment's Docker host over TLS, like
# deployment/<env>_env/deploy_to_<env>_env.sh. Run from the Jenkins workspace
# root with openlmis-config checked out in .deployment-config/.
# Usage: monitoring/alloy/deploy_alloy.sh <uat|test|v3-demo>
set -euo pipefail

ENV_NAME="${1:?usage: $0 <uat|test|v3-demo>}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${CONFIG_DIR:-$(pwd)/.deployment-config}"

# identity, ingest URLs + token, DOCKER_HOST
cp "${CONFIG_DIR}/${ENV_NAME}-alloy.env" "${HERE}/.env"
trap 'rm -f "${HERE}/.env"' EXIT
set -a; . "${HERE}/.env"; set +a

export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH="${CONFIG_DIR}/${ENV_NAME}-certs"

cd "${HERE}"
# Classic builder: BuildKit on the older app daemons drops the base image's
# ENTRYPOINT from FROM+COPY images.
DOCKER_BUILDKIT=0 docker build --build-arg "ALLOY_VERSION=${ALLOY_VERSION}" \
  -t "soldevelo-monitoring-alloy:${ALLOY_VERSION}" .
docker compose up -d
docker compose ps
