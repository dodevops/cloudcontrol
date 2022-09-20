#!/usr/bin/env bash

TERM=xterm

# CloudControl master control program

if [ "X$1X" == "XserveX" ]
then
  cd /usr/local/ccc || exit 1
  ./ccc 2>&1
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
    echo
    echo
    curl -H "Accept: text/plain" -s http://localhost:8080/api/features
    echo
  fi

  echo

  export PATH=$PATH:/home/cloudcontrol/bin

  if [ -n "${WORKDIR}" ]
  then
    cd "${WORKDIR}" || cd || exit
  fi

  # Start shell

  eval "$(cat /home/cloudcontrol/.shell)"

else

  echo "Invalid cloudcontrol argument $1"
  exit 1

fi
