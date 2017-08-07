#!/usr/bin/env bash

/usr/local/bin/docker-compose pull log
/usr/local/bin/docker-compose pull db
/usr/local/bin/docker-compose pull nginx
/usr/local/bin/docker-compose pull consul

# $1 is the parameter passed in
/usr/local/bin/docker-compose pull $1
