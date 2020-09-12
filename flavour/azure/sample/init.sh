#!/usr/bin/env bash

docker-compose pull
docker-compose up -d

echo "CloudControl is initializing. Check out http://$(docker-compose port cli 8080) for details"
