#!/usr/bin/env bash

echo "# CLOUD CONTROL SETUP"

echo "## AZURE"
echo

echo "azure" > /flavour

echo "Logging in..."
if ! az login
then
  echo "Can not login into Azure"
  exit 1
fi

if [ "X${AZ_SUBSCRIPTION}X" == "XX" ]
then
  echo -n "* Subscription: "
  read -r AZ_SUBSCRIPTION
  echo
fi

echo "Setting subscription..."
if ! az account set --subscription "${AZ_SUBSCRIPTION}"
then
  echo "Can not set subscription"
  exit 1
fi

source featureinstaller.sh

echo "# FINISHED"
echo
echo "To use CLOUD CONTROL, run run.sh from now on."
echo "Hit CTRL-C to exit now."

while true; do sleep 30; done;
