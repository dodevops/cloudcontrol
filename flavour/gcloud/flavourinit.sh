#!/usr/bin/env bash

. /feature-installer-utils.sh

if [ -z "$GCLOUD_KEYPATH" ]
then
  echo "Please set GCLOUD_KEYPATH environment variable"
  exit 1
fi

if [ ! -r "$GCLOUD_KEYPATH" ]
then
  echo "File ${GCLOUD_KEYPATH} is not readable"
  exit 1
fi

if [ -z "$GCLOUD_PROJECTID" ]
then
  echo "Please set GCLOUD_PROJECTID environment variable"
  exit 1
fi

execHandle "Authenticating service account" gcloud auth activate-service-account --key-file "$GCLOUD_KEYPATH"
execHandle "Setting project" gcloud config set project "$GCLOUD_PROJECTID"

exit 0
