#!/usr/bin/env bash

. /feature-installer-utils.sh

if [ -n "${AWS_MFA_ARN}" ]
then
  execHandle "Installing jq" sudo yum install -y jq
  echo "Please put the current code on your authenticator into the file /tmp/mfa."
  while [ ! -e "/tmp/mfa" ]
  do
    sleep 1
  done
  CODE=$(cat /tmp/mfa)
  /home/cloudcontrol/bin/createSession.sh "${CODE}"
  echo "A temporary session has been created. Run createSession.sh <MFA-code> again to update the session token."
else
  echo "AWS initialized"
fi

