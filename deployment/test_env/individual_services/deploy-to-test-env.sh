#!/usr/bin/env bash
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://elb-test-env-swarm-683069932.us-east-1.elb.amazonaws.com:2376"

#curl -LO https://raw.githubusercontent.com/OpenLMIS/openlmis-config/master/.env

docker network ls | grep 'openlmis-test-env-network'
if [ $? == 0 ]; then
   echo "found network, continue"
else
    echo "openlmis-test-env-network not found, going to create"
    docker network create --driver overlay openlmis-test-env-network
fi

docker service ls | grep 'requisition-db'
if [ $? == 0 ]; then
    echo "requisition DB service already exists"
else
    echo "requisition DB service does not exist yet, going to create"
    docker service create \
    --env POSTGRES_USER=postgres,POSTGRES_PASSWORD=p@ssw0rd \
    --network openlmis-test-env-network \
    --name requisition-db \
    openlmis/postgres:latest
    #docker service command does not support env file
fi

docker service ls | grep 'requisition'
if [ $? == 0 ]; then
    echo "requisition service already exists, going to update"
else
    echo "requisition service does not exist yet, going to create"
    docker service create \
        --env POSTGRES_USER=postgres,POSTGRES_PASSWORD=p@ssw0rd,DATABASE_URL=jdbc:postgresql://requisition-db:5432/open_lmis,BASE_URL=http://localhost:8080 \
        --network openlmis-test-env-network \
        --publish 8080:8080 \
        --name requisition \
        openlmis/requisition:latest
fi