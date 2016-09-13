#!/usr/bin/env bash
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://elb-test-env-swarm-683069932.us-east-1.elb.amazonaws.com:2376"

#curl -LO https://raw.githubusercontent.com/OpenLMIS/openlmis-config/master/.env

docker network ls | grep 'openlmis-test-env-network'
if [ $? == 0 ]; then
   echo "found network, continue"
else
    echo "openlmis-test-env-network not found, going to create"

    docker network create \
  --driver overlay \
  --subnet 192.168.1.0/24 \
  --opt encrypted \
  openlmis-test-env-network
fi

docker service ls | grep 'db'
if [ $? == 0 ]; then
    echo "requisition DB service already exists"
else
    echo "requisition DB service does not exist yet, going to create"
    docker service create \
    --network openlmis-test-env-network \
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=p@ssw0rd \
    --name db \
    --endpoint-mode dnsrr \
    openlmis/postgres:latest
    #docker service command does not support env file
fi

docker service ls | grep 'log'
if [ $? == 0 ]; then
    echo "log service already exists"
else
    echo "log service does not exist yet, going to create"
    docker service create \
    --network openlmis-test-env-network \
    --name log \
    --endpoint-mode dnsrr \
    openlmis/rsyslog:latest
    #docker service command does not support env file
fi

docker service ls | grep 'requisition'
if [ $? == 0 ]; then
    echo "requisition service already exists, going to update, TBD"
else
    echo "requisition service does not exist yet, going to create"
    docker service create \
    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=p@ssw0rd -e DATABASE_URL=jdbc:postgresql://db:5432/open_lmis -e BASE_URL=http://localhost:8080 \
    --network openlmis-test-env-network \
    --replicas 2 \
    --name requisition \
    --publish 8080:8080 \
    openlmis/requisition:latest
fi