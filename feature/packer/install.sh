. /feature-installer-utils.sh

PACKER_VERSION=$(checkAndCleanVersion "${PACKER_VERSION}")

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

execHandle "Downloading packer" curl -f -s -L "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_$(getPlatform).zip" --output packer.zip
execHandle "Unpacking packer" unzip packer.zip &>/dev/null
execHandle "Installing packer" mv packer /home/cloudcontrol/bin

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"
