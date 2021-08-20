# Execute a command and if it fails, return its output and exit
function execHandle {
  TITLE=$1
  shift
  echo "$TITLE..."
  if ! OUTPUT=$("$@" 2>&1)
  then
    echo "Error ${TITLE}: $OUTPUT"
    exit 1
  fi
}

# Wait for the user to enter a correct mfa code
function waitForMfaCode {
  if [ -z "${AWS_MFA_ARN}" ]
  then
    # No MFA required
    return
  fi
  source /home/cloudcontrol/.bashrc
  echo "Please put the current code on your authenticator into the file /tmp/mfa."
  CORRECT_CODE=1
  while [ ${CORRECT_CODE} != 0 ]
  do
    while [ ! -e "/tmp/mfa" ]
    do
      sleep 1
    done
    source ~/bin/createSession.bash "$(cat /tmp/mfa)"
    CORRECT_CODE=$?
    if [ $CORRECT_CODE != 0 ]
    then
      rm /tmp/mfa
      echo "Invalid code specified. Please try again"
    fi
  done
  echo "[VALID_CODE] Valid code entered. Thank you."
}
