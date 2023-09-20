#!/usr/bin/env bash

# CloudControl build script
# Usage:
#
# bash build.sh <tag> [<flavour>]
#
# If no flavour is specified, all flavours will be built

mv Dockerfile Dockerfile.sav

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
  cat build/Dockerfile.suffix.mo | docker run --rm -i -e FLAVOUR=${FLAVOUR} -e BUILD_DATE=$(date -Iseconds) metal3d/mo >> Dockerfile
  docker build --pull . -t "ghcr.io/dodevops/cloudcontrol-${FLAVOUR}:${TAG}"
done

if [ -e Dockerfile.sav ] ; then
  mv Dockerfile.sav Dockerfile
fi
