#!/usr/bin/env bash

docker pull openlmis/stop-instance

echo "Stopping EC2 instance for perftest server"
/usr/bin/docker run --rm --env-file .deployment-config/perftest.env openlmis/stop-instance

