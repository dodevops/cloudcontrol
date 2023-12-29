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
    # shellcheck source=/dev/null
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

function getPlatform {
  if [ "$(uname -m)" == 'aarch64' ]
  then
    echo 'arm64'
  elif [ "$(uname -m)" == 'x86_64' ]
  then
    echo 'amd64'
  else
    exit 1
  fi
}

function checkAndCleanVersion {
  VERSION=$1
  if [ "${VERSION:0:1}" == "v" ]
  then
    echo "[DEPRECATION WARNING] Versions with a \"v\" prefix are deprecated and will be removed in CloudControl 4.0. Please only use versions without the \"v\" prefix. (Got \"${VERSION}\")" >&2
    echo "${VERSION/#v/}"
  else
    echo "${VERSION}"
  fi
}

# Usage: downloadFromGithub USER REPO VERSION PACKAGE_PREFIX PACKAGE_SUFFIX TARGET
# Downloads a release package from github using the common architecture names
# The package will be downloaded from github.com/USER/REPO/releases/VERSION/download/PACKAGE to the given TARGET file
# where PACKAGE consists of PACKAGE_PREFIXARCHITECTURE.PACKAGE_SUFFIX.
# Example: PACKAGE_PREFIX=krew_linux_, PACKAGE_SUFFIX=tar.gz on an arm architecture will download krew_linux_arm64.tar.gz
function downloadFromGithub {
  USER=$1
  REPO=$2
  VERSION=$3
  PACKAGE_PREFIX=$4
  PACKAGE_SUFFIX=$5
  TARGET=$6

  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
  PACKAGE="${PACKAGE_PREFIX}${ARCH}.${PACKAGE_SUFFIX}"
  execHandle "Downloading ${USER}/${REPO}@${VERSION}" curl -f -s -L "https://github.com/${USER}/${REPO}/releases/${VERSION}/download/${PACKAGE}" --output "${TARGET}"
}