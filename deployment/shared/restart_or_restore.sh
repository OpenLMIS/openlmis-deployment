#!/usr/bin/env bash
set -e

BASE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)
TARGET_ENV="${1:-}"

if [ -z "$TARGET_ENV" ]; then
  echo "Error: No environment specified. Usage: ./restart_or_restore.sh <env_name> (e.g., uat_env)"
  exit 1
fi

ENV_PATH="$BASE_DIR/$TARGET_ENV"
if [ ! -d "$ENV_PATH" ]; then
  echo "Error: Environment directory not found at $ENV_PATH"
  exit 1
fi

: "${KEEP_OR_RESTORE:?Need to set KEEP_OR_RESTORE environment variable (keep|restore)}"

echo "========================================"
echo "Deploying to: $TARGET_ENV"
echo "Mode: $KEEP_OR_RESTORE"
echo "Base Dir: $BASE_DIR"
echo "========================================"

PROFILES=""
if [ -f "$ENV_PATH/.env" ]; then
    PROFILES=$(grep -v '^#' "$ENV_PATH/.env" | grep spring_profiles_active | sed -e 's/.*=//')
fi
if [ -z "$PROFILES" ] && [ -f "$ENV_PATH/settings.env" ]; then
    PROFILES=$(grep -v '^#' "$ENV_PATH/settings.env" | grep spring_profiles_active | sed -e 's/.*=//')
fi

: "${PROFILES:?Need to set spring_profiles_active - could not parse from .env or settings.env}"
echo "Profiles from env: $PROFILES"

echo "Full cleanup (Stopping containers, removing volumes)..."
docker compose kill
docker compose down -v --remove-orphans
docker image prune -f

if [ "$KEEP_OR_RESTORE" == "restore" ]; then
  echo ">>> MODE: RESTORE"
  echo "Resetting data based on spring_profiles_active."

  # Remove 'production' profile if active
  PROFILES="${PROFILES//production/}"

else
  echo ">>> MODE: KEEP"
  echo "Restarting services only. Preserving data."

  # Remove 'demo-data' and 'performance-data' profiles if active
  PROFILES="${PROFILES//demo-data/}"
  PROFILES="${PROFILES//performance-data/}"

  # Safety check
  if [[ "$PROFILES" != *"production"* ]]; then
    PROFILES="$PROFILES,production"
  fi
fi

PROFILES=$(echo "$PROFILES" | sed 's/,,/,/g' | sed 's/^,//' | sed 's/,$//')
export spring_profiles_active="$PROFILES"

echo "Final Profiles to use: $spring_profiles_active"

echo "Starting services in $ENV_PATH..."
cd "$ENV_PATH"
docker compose pull
docker compose up --build --force-recreate -d

echo "Done."
