#!/usr/bin/env bash

set -euo pipefail

# CloudControl build script
# Usage:
#
# bash build.sh [<tag> [<flavour>]]
#
# If no tag is given, latest will be used
# The flavour can only be specified, if a tag is given.
# If no flavour is specified, all flavours will be built

mv Dockerfile Dockerfile.sav  &>/dev/null || true

TAG="${1-latest}"
EXISTING_FLAVOURS=$(find flavour -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | paste -s -d ' ' -)" "
FLAVOURS=''
if [[ $# -ne 2 ]]
then
  FLAVOURS=${EXISTING_FLAVOURS}
else
  if [[ "${EXISTING_FLAVOURS}" == *"$2 "*  ]]
  then
    FLAVOURS=$2
  else
    >&2  echo "The flavour '$2' does not exist!"
    exit 1
  fi
fi

for FLAVOUR in ${FLAVOURS}
do
  cat build/Dockerfile.prefix > Dockerfile
  cat "flavour/${FLAVOUR}/Dockerfile.flavour" >> Dockerfile
  cat build/Dockerfile.suffix.mo | docker run --rm -i -e FLAVOUR=${FLAVOUR} -e BUILD_DATE="$(date -Iseconds)" ghcr.io/tests-always-included/mo:3.0.5 >> Dockerfile
  docker build --pull . --no-cache -t "ghcr.io/dodevops/cloudcontrol-${FLAVOUR}:${TAG}"
done

if [ -e Dockerfile.sav ] ; then
  mv Dockerfile.sav Dockerfile
fi
