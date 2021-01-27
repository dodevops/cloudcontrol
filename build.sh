#!/usr/bin/env bash

# CloudControl build script
# Usage:
#
# bash build.sh <tag> [<flavour>]
#
# If no flavour is specified, all flavours will be built

TAG=latest
if [ -n "$1" ]
then
  TAG=$1
fi

FLAVOURS=""
if [ -n "$1" ] && [ -z "$2" ] || [ -z "$1" ]
then
  FLAVOURS=$(find flavour -maxdepth 1 -type d -exec basename {} \; | grep -v flavour | paste -s -d " " -)
else
  FLAVOURS=$2
fi

for FLAVOUR in ${FLAVOURS}
do
  cat build/Dockerfile.prefix > Dockerfile
  cat "flavour/${FLAVOUR}/Dockerfile.flavour" >> Dockerfile
  cat build/Dockerfile.suffix >> Dockerfile
  docker build . -t "dodevops/cloudcontrol-${FLAVOUR}:${TAG}"
done

rm Dockerfile
