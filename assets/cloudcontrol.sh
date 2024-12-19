#!/usr/bin/env bash

TERM=xterm

# CloudControl master control program

if [ "X$1X" == "XserveX" ]
then
  cd /usr/local/ccc || exit 1
  if [ -z "${DEBUG_CCC}" ]
  then
    export GIN_MODE=release
    ./ccc 2>&1
  else
    ./ccc --loglevel debug 2>&1
  fi
elif [ "X$1X" == "XrunX" ]
then
  if [ "X${MOTD}X" != "XX" ]
  then
    echo "${MOTD}"
  else
    MOTD_DISPLAY_DEFAULT=yes
  fi

  export PATH=$PATH:/home/cloudcontrol/bin

  if [ "X${MOTD_DISPLAY_DEFAULT}X" == "XyesX" ]
  then
    echo
    echo
    curl -H "Accept: text/plain" -s http://localhost:8080/api/features | markdown
    echo
  fi

  echo

  if [ -r /home/cloudcontrol/.deprecation ];
  then
    echo "# ⚠️ Deprecation" | markdown
    echo
    echo "The following deprecations were found:"
    echo "---" | markdown
    markdown < /home/cloudcontrol/.deprecation
  fi

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
