#!/usr/bin/env bash

if [ "X${MOTD}X" != "XX" ]
then
  echo "${MOTD}"
else
  MOTD_DISPLAY_DEFAULT=yes
fi

if [ "X${MOTD_DISPLAY_DEFAULT}X" == "XyesX" ]
then
  echo "# CLOUD CONTROL"
  echo
  echo "Welcome to CLOUD CONTROL. I have installed and configured the following features:"
  echo

  while IFS= read -r FEATURE
  do
    echo "* ${FEATURE}"
    echo
    if [ -r /home/cloudcontrol/feature-installers/${FEATURE}/motd.sh ]
    then
      source /home/cloudcontrol/feature-installers/${FEATURE}/motd.sh
    fi
    echo
  done < "$(cat /home/cloudcontrol/features)"
fi

export PATH=$PATH:/home/cloudcontrol/bin

# Start shell

eval "$(cat /home/cloudcontrol/.shell)"
