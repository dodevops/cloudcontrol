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

  while IFS= read -r FEATURE
  do
    echo
    echo "* ${FEATURE}"
    if [ -r /home/cloudcontrol/feature-installers/${FEATURE}/motd.sh ]
    then
      echo
      source /home/cloudcontrol/feature-installers/${FEATURE}/motd.sh
    fi
  done < /home/cloudcontrol/features
fi

export PATH=$PATH:/home/cloudcontrol/bin

# Start shell

eval "$(cat /home/cloudcontrol/.shell)"
