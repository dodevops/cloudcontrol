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
  cat <<EOF >>~/.bashrc
ORIGINAL_AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ORIGINAL_AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
alias createSession="source ~/bin/createSession.bash"
EOF
else
  echo "AWS initialized"
fi

