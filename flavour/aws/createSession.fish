#!/usr/bin/env fish

if test (count $argv) -ne 1
  echo "Usage: source createSession.sh <token code>"
	exit 1
end

set CODE $argv[1]

set AWS_ACCESS_KEY_ID $ORIGINAL_AWS_ACCESS_KEY_ID
set AWS_SECRET_ACCESS_KEY $ORIGINAL_AWS_SECRET_ACCESS_KEY

set TOKENS (aws sts get-session-token --serial-number $AWS_MFA_ARN --token-code $CODE)

if test $status -ne 0
    exit 1
end

set -x AWS_SESSION_TOKEN (echo "$TOKENS"| jq -r .Credentials.SessionToken)
set -x AWS_ACCESS_KEY_ID (echo "$TOKENS"| jq -r .Credentials.AccessKeyId)
set -x AWS_SECRET_ACCESS_KEY (echo "$TOKENS"| jq -r .Credentials.SecretAccessKey)
