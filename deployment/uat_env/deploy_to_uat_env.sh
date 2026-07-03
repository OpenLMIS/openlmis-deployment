#!/usr/bin/env bash
#
# Deploys OpenLMIS UAT to uat.openlmis.org, then deploys the reporting-stack
# (openlmis-reporting platform) onto the SAME Docker host.
#
# Jenkins workspace layout assumed:
#   $WORKSPACE/
#     openlmis-deployment/       (this repo, checked out at the workspace root)
#     .deployment-config/        (openlmis-config, private; subdir)
#     openlmis-reporting/        (reporting-stack platform repo; subdir)
#
# Inputs:
#   KEEP_OR_RESTORE        env var (Jenkins choice param: "keep" | "restore"),
#                          required by restart_or_restore.sh. On "restore" the
#                          demo-data profiles drop and recreate the source
#                          tables, so the reporting stack is reset too.
#   SKIP_REPORTING_STACK=1 skips the reporting-stack part (OLMIS-only redeploy).
#   REPORTING_SSH_KEY      overrides the SSH private key path (e.g. from a
#                          Jenkins credentials binding).
#   REPORTING_OLD_DOCKER=1 forces the old-Docker workarounds (classic-builder
#                          pre-build + seccomp overlay); otherwise they are
#                          applied automatically when the host daemon is < 20.x.
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# =============================================================================
# 1. OpenLMIS deploy
# =============================================================================
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://uat.openlmis.org:2376"
export DOCKER_CERT_PATH="${SCRIPT_DIR}/uat-certs"

# Refreshes the instance state by removing all local artifacts (containers, networks, dangling images).
# The database volume must be external to survive the volume cleanup step.
"$SCRIPT_DIR/../shared/restart_or_restore.sh" "uat_env"

# =============================================================================
# 2. Reporting-stack deploy
# =============================================================================
# The reporting-stack compose uses local bind mounts (../scripts, ../airflow/dags,
# etc.), so it can't be deployed by pointing DOCKER_HOST at the remote daemon —
# the daemon would look for those paths on its own filesystem. We instead rsync
# the openlmis-reporting checkout to a fixed path on uat.openlmis.org and run
# `make up && make setup` over SSH.

if [ "${SKIP_REPORTING_STACK:-0}" = "1" ]; then
  echo "SKIP_REPORTING_STACK=1 set — skipping reporting-stack deploy."
  exit 0
fi

# All Jenkins SCMs check out UNDER the workspace root:
#   openlmis-deployment       -> workspace root (no subdir; this repo)
#   openlmis-config           -> ./.deployment-config (subdir)
#   soldevelo-reporting-stack -> ./openlmis-reporting (subdir)
# $WORKSPACE is always set by Jenkins. The fallback derives the workspace root
# from this script's location (deployment/uat_env -> repo root == workspace root).
WORKSPACE_ROOT="${WORKSPACE:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"

REPORTING_REPO_LOCAL="${REPORTING_REPO_LOCAL:-${WORKSPACE_ROOT}/openlmis-reporting}"
REPORTING_REMOTE_HOST="${REPORTING_REMOTE_HOST:-uat.openlmis.org}"
REPORTING_REMOTE_USER="${REPORTING_REMOTE_USER:-ubuntu}"
REPORTING_REMOTE_PATH="${REPORTING_REMOTE_PATH:-/opt/reporting-stack}"

CONFIG_DIR="${WORKSPACE_ROOT}/.deployment-config"
SSH_KEY="${REPORTING_SSH_KEY:-${CONFIG_DIR}/uat-ssh/id_rsa}"
ENV_REPORTING="${CONFIG_DIR}/uat-reporting-stack.env"
CDC_SQL="${SCRIPT_DIR}/reporting-stack/reporting-stack-cdc.sql"

if [ ! -d "$REPORTING_REPO_LOCAL" ]; then
  echo "ERROR: openlmis-reporting checkout not found at $REPORTING_REPO_LOCAL" >&2
  echo "Add it as an SCM source in the Jenkins job (see reporting-stack-rollout.md)." >&2
  exit 1
fi
if [ ! -f "$SSH_KEY" ]; then
  echo "ERROR: SSH key not found at $SSH_KEY" >&2
  echo "Provide it via a Jenkins credentials binding (REPORTING_SSH_KEY) or in openlmis-config." >&2
  exit 1
fi
if [ ! -f "$ENV_REPORTING" ]; then
  echo "ERROR: uat-reporting-stack.env not found at $ENV_REPORTING" >&2
  echo "Add it to openlmis-config (see reporting-stack-rollout.md)." >&2
  exit 1
fi
if [ ! -f "$CDC_SQL" ]; then
  echo "ERROR: CDC bootstrap SQL not found at $CDC_SQL" >&2
  exit 1
fi

# SSH refuses to use keys with loose permissions; rsync inherits that.
chmod 600 "$SSH_KEY"

SSH_OPTS="-i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"
SSH_TARGET="${REPORTING_REMOTE_USER}@${REPORTING_REMOTE_HOST}"

echo "=== Reporting-stack deploy ==="
echo "Target: ${SSH_TARGET}:${REPORTING_REMOTE_PATH}"
echo "Mode:   ${KEEP_OR_RESTORE:-keep}"

# Stage .env on the Jenkins side so it gets rsync'd in.
cp "$ENV_REPORTING" "$REPORTING_REPO_LOCAL/.env"

# Ensure remote path exists and is owned by the deploy user.
ssh $SSH_OPTS "$SSH_TARGET" "sudo mkdir -p '$REPORTING_REMOTE_PATH' && sudo chown -R '$REPORTING_REMOTE_USER':'$REPORTING_REMOTE_USER' '$REPORTING_REMOTE_PATH'"

echo "Syncing repo..."
rsync -az --delete \
  -e "ssh $SSH_OPTS" \
  --exclude='.git/' \
  --exclude='.bootstrap/' \
  --exclude='.packages/' \
  --exclude='.dbt/' \
  --exclude='.deploy/' \
  "$REPORTING_REPO_LOCAL/" \
  "${SSH_TARGET}:${REPORTING_REMOTE_PATH}/"

# Ship the CDC bootstrap SQL alongside the repo (outside the rsync'd tree).
ssh $SSH_OPTS "$SSH_TARGET" "mkdir -p '$REPORTING_REMOTE_PATH/.deploy'"
scp $SSH_OPTS "$CDC_SQL" "${SSH_TARGET}:${REPORTING_REMOTE_PATH}/.deploy/reporting-stack-cdc.sql"

echo "Running make up && make setup on remote host..."
ssh $SSH_OPTS "$SSH_TARGET" "KEEP_OR_RESTORE='${KEEP_OR_RESTORE:-keep}' REPORTING_REMOTE_PATH='$REPORTING_REMOTE_PATH' REPORTING_OLD_DOCKER='${REPORTING_OLD_DOCKER:-0}' bash -s" <<'REMOTE'
set -euo pipefail
cd "$REPORTING_REMOTE_PATH"

# On 'restore', the demo-data spring profiles drop and recreate the OLMIS
# source tables — CDC offsets are stale and the publication membership is
# lost, so reset the reporting-stack volumes and let Debezium re-snapshot.
if [ "${KEEP_OR_RESTORE:-keep}" = "restore" ]; then
  echo "KEEP_OR_RESTORE=restore — resetting reporting-stack volumes for fresh snapshot."
  make reset || true
fi

# --- dbt-directory perms + AIRFLOW_DOCKER_GID alignment ---------------------
# The Airflow scheduler runs as uid 50000 with group_add: ["$AIRFLOW_DOCKER_GID"]
# so it can talk to /var/run/docker.sock. The same supplementary group is what
# lets it (and host-shell operators running as `ubuntu`) write into the dbt
# directory — specifically packages.yml, which scripts/dbt/run.sh regenerates.
#
# Two things have to be in sync:
#   1. .env must carry the host's docker-group GID so compose's group_add
#      receives the right value. We auto-detect from /var/run/docker.sock here
#      so the deploy survives host rebuilds (the GID can shift between
#      installs) without hand-editing openlmis-config.
#   2. The dbt/ directory must be group-owned by that GID and group-writable
#      so a freshly rsync'd tree (default 0644 ubuntu:ubuntu) doesn't lock
#      out the airflow uid the first time the DAG runs.
DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
echo "Host docker.sock gid: $DOCKER_GID — applying to .env and dbt/ perms."

if grep -q '^AIRFLOW_DOCKER_GID=' .env; then
  sed -i "s|^AIRFLOW_DOCKER_GID=.*|AIRFLOW_DOCKER_GID=$DOCKER_GID|" .env
else
  echo "AIRFLOW_DOCKER_GID=$DOCKER_GID" >> .env
fi

chgrp -R "$DOCKER_GID" dbt
chmod -R g+rwX dbt

# --- Old-Docker workaround (only when the host daemon is < 20.x) -------------
# Two issues with Docker 19.03-era daemons (cf. the Malawi dev host):
#  1) BuildKit (compose's default builder) STRIPS the inherited Cmd/Entrypoint
#     from FROM+COPY images -> containers fail to start with "No command
#     specified". The classic builder (DOCKER_BUILDKIT=0) preserves it, so we
#     pre-build the custom images here; `make up` then reuses them (no rebuild).
#  2) The old libseccomp rejects the clone3 syscall. The seccomp-unconfined
#     compose overlay (+ DBT_DOCKER_SECCOMP in .env for the dbt run) covers
#     RUNTIME clone3.
# On a modern daemon both workarounds are skipped. Force with
# REPORTING_OLD_DOCKER=1 if auto-detection misjudges the host.
DOCKER_SERVER_VERSION=$(docker version --format '{{.Server.Version}}')
DOCKER_SERVER_MAJOR=${DOCKER_SERVER_VERSION%%.*}
if [ "${REPORTING_OLD_DOCKER:-0}" = "1" ] || [ "$DOCKER_SERVER_MAJOR" -lt 20 ]; then
  echo "Docker $DOCKER_SERVER_VERSION — pre-building custom images with the classic builder..."
  for spec in kafka-connect:connect airflow:airflow superset:superset; do
    name="${spec%%:*}"; ctx="${spec##*:}"
    DOCKER_BUILDKIT=0 docker build -t "soldevelo-reporting-stack/${name}:latest" "$ctx"
  done
  export COMPOSE_OVERLAY=compose/docker-compose.seccomp-unconfined.yml
  if ! grep -q '^DBT_DOCKER_SECCOMP=' .env; then
    echo "DBT_DOCKER_SECCOMP=unconfined" >> .env
  fi
else
  echo "Docker $DOCKER_SERVER_VERSION — no old-Docker workarounds needed."
fi

make up

# --- CDC objects on the source RDS -------------------------------------------
# UAT has no snapshot-restore hook (restore = demo-data reload via spring
# profiles), so the idempotent CDC bootstrap SQL is re-applied on EVERY deploy.
# On a restore build the OLMIS services are still running Flyway + demo-data
# at this point, so first wait (bounded) until all allowlisted source tables
# exist; on a keep build the tables are already there and the wait is a no-op.
get_env() { grep "^$1=" .env | head -n1 | cut -d= -f2-; }
SOURCE_PG_HOST=$(get_env SOURCE_PG_HOST)
SOURCE_PG_PORT=$(get_env SOURCE_PG_PORT)
SOURCE_PG_DB=$(get_env SOURCE_PG_DB)
SOURCE_PG_USER=$(get_env SOURCE_PG_USER)
SOURCE_PG_PASSWORD=$(get_env SOURCE_PG_PASSWORD)
SOURCE_PG_SSLMODE=$(get_env SOURCE_PG_SSLMODE)
ALLOWLIST=$(get_env SOURCE_PG_TABLE_ALLOWLIST)

# No -i: it would drain the stdin that feeds this script (bash -s).
psql_rds() {
  docker run --rm -v "$REPORTING_REMOTE_PATH/.deploy:/sql:ro" -e PGPASSWORD="$SOURCE_PG_PASSWORD" postgres:14-alpine \
    psql "host=$SOURCE_PG_HOST port=${SOURCE_PG_PORT:-5432} dbname=$SOURCE_PG_DB user=$SOURCE_PG_USER sslmode=${SOURCE_PG_SSLMODE:-require}" \
    -v ON_ERROR_STOP=1 "$@"
}

EXPECTED=$(echo "$ALLOWLIST" | tr ',' '\n' | grep -c .)
IN_LIST=$(echo "$ALLOWLIST" | tr ',' '\n' | sed "s/\([^.]*\)\.\(.*\)/('\1','\2')/" | paste -sd, -)

# On restore, table EXISTENCE is not enough: the pre-restore tables still
# exist while Flyway is only starting its clean, so an early apply gets
# silently undone when the tables are recreated. Apply, then confirm the
# publication membership HOLDS across a stability window, re-applying until
# it does. On keep builds the single apply is final (no Flyway churn).
PUB_EXPECTED=$(( EXPECTED + 1 ))   # allowlist + public.debezium_signal
echo "Waiting for the $EXPECTED allowlisted source tables to exist on RDS..."
DEADLINE=$(( $(date +%s) + 2700 ))
while :; do
  COUNT=$(psql_rds -tA -c "SELECT count(*) FROM information_schema.tables WHERE (table_schema, table_name) IN ($IN_LIST);" || echo 0)
  if [ "$COUNT" = "$EXPECTED" ]; then
    echo "All $EXPECTED source tables present — applying CDC objects (heartbeat, signal, publication)..."
    psql_rds -f /sql/reporting-stack-cdc.sql
    if [ "${KEEP_OR_RESTORE:-keep}" != "restore" ]; then
      break
    fi
    sleep 60
    PUB_COUNT=$(psql_rds -tA -c "SELECT count(*) FROM pg_publication_tables WHERE pubname='dbz_publication';" || echo 0)
    if [ "$PUB_COUNT" = "$PUB_EXPECTED" ]; then
      echo "Publication membership stable at $PUB_COUNT tables."
      break
    fi
    echo "  publication dropped to $PUB_COUNT/$PUB_EXPECTED (Flyway recreating tables) — re-applying..."
  else
    echo "  $COUNT/$EXPECTED tables present — retrying in 30s..."
    sleep 30
  fi
  if [ "$(date +%s)" -ge "$DEADLINE" ]; then
    echo "ERROR: timed out waiting for stable CDC objects ($COUNT/$EXPECTED tables)." >&2
    exit 1
  fi
done

# Git-mode packages: clone core (+ extensions if configured) to .packages/ so
# the connector and Superset importers (run by `make setup`) pick them up. dbt
# fetches its own copy via packages.yml. No-op in local mode
# (ANALYTICS_CORE_GIT_URL unset).
make package-fetch
make setup

# 'make reset' wiped ClickHouse on restore — rebuild the curated marts now
# instead of leaving dashboards empty until the hourly Airflow DAG.
if [ "${KEEP_OR_RESTORE:-keep}" = "restore" ]; then
  make initial-dbt-build
fi
REMOTE

echo "=== Done ==="
