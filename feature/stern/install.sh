. /feature-installer-utils.sh

if [ -z "${STERN_VERSION}" ]
then
  echo "The stern feature requires a version set using STERN_VERSION. See https://github.com/stern/stern/releases/ for valid versions"
  exit 1
fi

STERN_VERSION=$(checkAndCleanVersion "${STERN_VERSION}")

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

execHandle "Downloading stern" curl -f -s -L "https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_$(getPlatform).tar.gz" --output stern.tar.gz
execHandle "Unpacking stern" tar xzf stern.tar.gz

execHandle "Installing stern" mv stern /home/cloudcontrol/bin

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"




