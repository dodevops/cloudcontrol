#!/usr/bin/env bash

set -x

CODE=$1

export AWS_SESSION_TOKEN=$(aws sts get-session-token --serial-number "${AWS_MFA_ARN}" --token-code "${CODE}" | jq -r .Credentials.SessionToken)
echo "${AWS_SESSION_TOKEN}" > /tmp/session
