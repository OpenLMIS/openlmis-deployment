#!/usr/bin/env bash

if [ $KEEP_OR_WIPE == "wipe" ];
#when run locally, and the env var is not present, else branch will run, thus to keep data
then
echo "will WIPE data!!"
/usr/local/bin/docker-compose down -v
else
echo "will keep data";
/usr/local/bin/docker-compose down
fi

/usr/local/bin/docker-compose up -d


docker exec -d nginx-proxy wget https://raw.githubusercontent.com/OpenLMIS/openlmis-deployment/master/deployment/shared/nginx.tmpl -O /app/nginx.tmpl
docker restart nginx-proxy