#!/usr/bin/env bash

docker-compose pull
docker-compose up -d
docker-compose logs --tail=0 -f cli
