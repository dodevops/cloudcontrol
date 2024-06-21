. /feature-installer-utils.sh

if [ -z "${SOPS_VERSION}" ]
then
  echo "The sops feature requires a version set using SOPS_VERSION. See https://github.com/getsops/sops/releases/ for valid versions"
  exit 1
fi

SOPS_VERSION=$(checkAndCleanVersion "${SOPS_VERSION}")

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

execHandle "Downloading sops" curl -f -s -L "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.$(getPlatform)" --output sops
execHandle "Installing sops" mv sops /home/cloudcontrol/bin
execHandle "Making sops executable" chmod +x /home/cloudcontrol/bin/sops

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"




