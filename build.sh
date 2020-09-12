#!/usr/bin/env bash

FLAVOURS=""
if [ -z "$1" ]
then
  FLAVOURS=$(find flavour -type d -depth 1 -exec basename {} \; | paste -s -d " ")
else
  FLAVOURS=$1
fi

TAG=latest
if [ -n "$2" ]
then
  TAG=$2
fi

for FLAVOUR in ${FLAVOURS}
do
  cat build/Dockerfile.prefix > Dockerfile
  cat "flavour/${FLAVOUR}/Dockerfile.flavour" >> Dockerfile
  cat build/Dockerfile.suffix >> Dockerfile
  docker build . -t "dodevops/cloudcontrol-${FLAVOUR}:${TAG}"
done

rm Dockerfile
