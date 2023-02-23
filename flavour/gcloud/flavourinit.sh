#!/usr/bin/env bash

. /feature-installer-utils.sh

if [ "X${GCLOUD_USE_SA:-false}X" == "XtrueX" ] && [ -z "$GCLOUD_KEYPATH" ]
then
  echo "Please set GCLOUD_KEYPATH environment variable"
  exit 1
fi

if [ "X${GCLOUD_USE_SA:-false}X" == "XtrueX" ] && [ ! -r "$GCLOUD_KEYPATH" ]
then
  echo "File ${GCLOUD_KEYPATH} is not readable"
  exit 1
fi

if [ -z "$GCLOUD_PROJECTID" ]
then
  echo "Please set GCLOUD_PROJECTID environment variable"
  exit 1
fi

if [ "X${GCLOUD_USE_SA:-false}X" == "XtrueX" ]
then
  execHandle "Authenticating service account" gcloud auth activate-service-account --key-file "$GCLOUD_KEYPATH"
else
  execHandle "Authenticating service account" gcloud auth login
fi
execHandle "Setting project" gcloud config set project "$GCLOUD_PROJECTID"

exit 0
