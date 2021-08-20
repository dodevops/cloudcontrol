#!/usr/bin/env bash

if [ "$#" -ne 1 ]
then
  echo "Usage: source createSession.sh <token code>"
  return 1
fi

CODE=$1

AWS_ACCESS_KEY_ID=${ORIGINAL_AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${ORIGINAL_AWS_SECRET_ACCESS_KEY}

if ! TOKENS=$(aws sts get-session-token --serial-number "${AWS_MFA_ARN}" --token-code "${CODE}")
then
  return 1
fi

export AWS_SESSION_TOKEN=$(echo "$TOKENS"| jq -r .Credentials.SessionToken)
export AWS_ACCESS_KEY_ID=$(echo "$TOKENS"| jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo "$TOKENS"| jq -r .Credentials.SecretAccessKey)
