. /feature-installer-utils.sh

if [ -z "${PACKER_VERSION}" ]
then
  echo "The packer feature requires a version set using PACKER_VERSION. See https://github.com/hashicorp/packer/releases for valid versions"
  exit 1
fi

PACKER_VERSION=$(checkAndCleanVersion "${PACKER_VERSION}")

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

execHandle "Downloading packer" curl -f -s -L "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_$(getPlatform).zip" --output packer.zip
execHandle "Unpacking packer" unzip packer.zip &>/dev/null
execHandle "Installing packer" mv packer /home/cloudcontrol/bin

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"
