#!/usr/bin/env bash

if [ ! -e /home/cloudcontrol/initialization.done ]
then
  echo "# CLOUD CONTROL SETUP"

  echo "## AWS"
  echo

  # Set flavour
  echo "aws" > /home/cloudcontrol/flavour

  source /feature-installer.sh

  echo "# FINISHED"
  echo
  echo "To use CLOUD CONTROL, run run.sh from now on."
  echo "Hit CTRL-C to exit now."

  touch /home/cloudcontrol/initialization.done
else
  echo "# FINISHED"
  echo
  echo "Cloud Control already initialized. Remove /home/cloudcontrol/initialization.done to reinitialize."
  echo
  echo "To use CLOUD CONTROL, run run.sh from now on."
  echo "Hit CTRL-C to exit now."
fi

while true; do sleep 30; done;
