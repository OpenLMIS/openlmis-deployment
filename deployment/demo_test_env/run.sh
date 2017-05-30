#!/usr/bin/env bash

############################################################################
# Useful for testing whether migration to new version is working properly. #
############################################################################

/usr/local/bin/docker-compose -f docker-compose.stable-version.yml down --volumes
/usr/local/bin/docker-compose -f docker-compose.new-version.yml down --volumes

/usr/local/bin/docker-compose -f docker-compose.stable-version.yml pull

# run old component versions that will load old demo data to database
/usr/local/bin/docker-compose -f docker-compose.stable-version.yml up  --build --force-recreate -d

sleep 3m

/usr/local/bin/docker-compose -f docker-compose.stable-version.yml stop

docker rm -f demotestenv_auth_1
docker rm -f demotestenv_referencedata_1
docker rm -f demotestenv_requisition_1
docker rm -f demotestenv_fulfillment_1
docker rm -f demotestenv_log_1
docker rm -f demotestenv_ftp_1
docker rm -f demotestenv_nginx_1
docker rm -f demotestenv_reference-ui_1
docker rm -f demotestenv_consul_1
docker rm -f demotestenv_service-configuration_1

# run new component versions with production flag (no data loss)
/usr/local/bin/docker-compose -f docker-compose.new-version.yml up -d

sleep 3m

docker exec -i demotestenv_log_1 sh -c "cat /var/log/messages"
test_result=`docker exec -i demotestenv_log_1 sh -c "cat /var/log/messages" | grep ERROR | wc -l`

/usr/local/bin/docker-compose -f docker-compose.stable-version.yml down --volumes
/usr/local/bin/docker-compose -f docker-compose.new-version.yml down --volumes

exit ${test_result}
