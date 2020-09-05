#!/usr/bin/env bash

# CloudControl master control program

if [ "X$1X" == "XserveX" ]
then
  echo "Starting CloudControl"
  echo "---------------------"
  echo
  echo "Please wait for CloudControl to initialize. For details, open"
  echo
  echo "    http://localhost:${CCC_PORT}/"
  /home/cloudcontrol/bin/ccc
elif [ "X$1X" == "XrunX" ]
then
  if [ "X${MOTD}X" != "XX" ]
  then
    echo "${MOTD}"
  else
    MOTD_DISPLAY_DEFAULT=yes
  fi

  if [ "X${MOTD_DISPLAY_DEFAULT}X" == "XyesX" ]
  then
    TEMPFILE=$(mktemp)
    while IFS= read -r FEATURE
    do
      echo >> "$TEMPFILE"
      echo "* ${FEATURE}" >> "$TEMPFILE"
      if [ -r "/home/cloudcontrol/feature-installers/${FEATURE}/motd.sh" ]
      then
        echo >> "$TEMPFILE"
        "/home/cloudcontrol/feature-installers/${FEATURE}/motd.sh" >> "$TEMPFILE"
      fi
    done < /home/cloudcontrol/features

    echo "$TEMPFILE" | dialog --backtitle "CloudControl" --title "Welcome to CloudControl" --progressbox "Welcome to CloudControl. I have installed and configured the following features:" 20 60
  fi

  export PATH=$PATH:/home/cloudcontrol/bin

  # Start shell

  eval "$(cat /home/cloudcontrol/.shell)"

else

  echo "Invalid cloudcontrol argument $1"
  exit 1

fi
