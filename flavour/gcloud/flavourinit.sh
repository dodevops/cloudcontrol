#!/usr/bin/env bash

. /feature-installer-utils.sh

if [ "X${GCLOUD_USE_SA:-false}X" == "XtrueX" ]
then
  echo "Use of GCLOUD_USE_SA is deprecated, please simply set GOOGLE_CREDENTIALS to the path of a service account"
  echo "key file."
  if [ -z "${GCLOUD_KEYPATH}" ]
  then
    echo "GCLOUD_USE_SA was enabled, but GCLOUD_KEYPATH was not set."
    exit 1
  fi
  GOOGLE_CREDENTIALS="${GCLOUD_KEYPATH}"
fi

if [ -n "${GOOGLE_CREDENTIALS}" ]
then
  execHandle "Authenticating service account" gcloud auth activate-service-account --key-file "${GOOGLE_CREDENTIALS}"
else
  execHandle "Installing expect" sudo apk add expect
  expect /home/cloudcontrol/bin/login.expect
fi

if [ -n "${GCLOUD_PROJECTID}" ]
then
  echo "Usage of GCLOUD_PROJECTID is deprecated. Please use GOOGLE_PROJECT instead."
  GOOGLE_PROJECT="${GCLOUD_PROJECTID}"
fi

if [ -n "${GOOGLE_PROJECT}" ]
then
  execHandle "Setting project" gcloud config set project "${GOOGLE_PROJECT}"
fi

exit 0
