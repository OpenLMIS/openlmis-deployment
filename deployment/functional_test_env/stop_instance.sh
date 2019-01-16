#!/usr/bin/env bash

docker pull openlmis/stop-instance
echo "Stopping EC2 instance for functional test server"
/usr/bin/docker run --rm --env-file settings.env openlmis/stop-instance

