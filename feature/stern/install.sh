. /feature-installer-utils.sh

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

execHandle "Downloading stern" curl -f -s -L "https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64" --output stern
execHandle "Preparing stern" chmod +x stern
execHandle "Installing stern" mv stern /home/cloudcontrol/bin

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"




