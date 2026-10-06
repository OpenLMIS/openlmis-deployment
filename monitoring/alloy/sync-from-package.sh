#!/usr/bin/env bash
# Refresh config.alloy from the soldevelo-monitoring package at the tag in
# PACKAGE_VERSION. config.alloy is never edited here: OpenLMIS additions live in
# openlmis.alloy. `--check` only compares, and exits non-zero on drift.
set -euo pipefail
cd "$(dirname "$0")"

TAG="$(tr -d '[:space:]' < PACKAGE_VERSION)"
URL="https://raw.githubusercontent.com/SolDevelo/soldevelo-monitoring/${TAG}/agents-alloy/config.alloy"
TMP="$(mktemp)"; trap 'rm -f "$TMP"' EXIT
curl -fsSL "$URL" -o "$TMP"

if [[ "${1:-}" == "--check" ]]; then
  if diff -u "$TMP" config.alloy; then echo "config.alloy matches ${TAG}"; else
    echo "config.alloy differs from ${TAG} — run $0 (without --check)" >&2; exit 1; fi
else
  cp "$TMP" config.alloy
  echo "config.alloy synced to ${TAG}"
fi
