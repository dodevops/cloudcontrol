. /feature-installer-utils.sh

if [ -n "${GIT_VERSION}" ]
then
  GIT_VERSION=$(checkAndCleanVersion "${GIT_VERSION}")
  echo "Using git version ${GIT_VERSION}..."
fi

FLAVOUR="X$(cat /home/cloudcontrol/flavour)X"
if [[ "X${FLAVOUR}X" =~ X(azure|simple|tanzu|gcloud)X ]]
then
  execHandle "Installing git" sudo apk add git
elif [ "${FLAVOUR}" == "XawsX" ]
then
  if [ -n "${GIT_VERSION}" ]
  then
    execHandle "Installing git" sudo yum install -y git-${GIT_VERSION}
  else
    execHandle "Installing git" sudo yum install -y git
  fi
fi