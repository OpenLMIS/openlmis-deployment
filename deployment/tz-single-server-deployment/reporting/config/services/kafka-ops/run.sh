#!/bin/bash

set -e

: "${KAFKA_BROKER:?ERROR: Env var KAFKA_BROKER not set}"

julie-ops-cli.sh \
    --brokers "$KAFKA_BROKER" \
    --clientConfig ./topology-builder.properties \
    --topology topology