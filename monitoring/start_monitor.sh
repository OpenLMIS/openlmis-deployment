curl -sL https://github.com/OpenLMIS/openlmis-deployment/archive/master.tar.gz | tar xz

cd ./openlmis-deployment-master/monitoring

curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > docker-compose

chmod +x docker-compose

docker-compose up -d