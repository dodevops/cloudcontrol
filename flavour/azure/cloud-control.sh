#!/usr/bin/env bash

echo "# CLOUD CONTROL"
echo
echo "Welcome to CLOUD CONTROL. I have installed and configured the following features:"

cat /home/cloudcontrol/features

if grep terraform /home/cloudcontrol/features
then
  echo "You already are in your main terraform directory. Go to the configuration you need and run"
  echo "    terraform init -backend-config=/credentials.terraform"
  echo "to initialize the configuration. Afterwards, run the terraform commands with the"
  echo "parameter -var-file set to /credentials.terraform"
  cd /terraform
fi

export PATH=$PATH:/home/cloudcontrol/bin

if grep fish /home/cloudcontrol/features
then
  fish
else
  bash
fi
