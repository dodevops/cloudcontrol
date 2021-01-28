. /feature-installer-utils.sh

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

execHandle "Downloading azcopy" curl -f -s -L https://aka.ms/downloadazcopy-v10-linux -o azcopy.tar.gz
execHandle "Extracting azcopy" tar xzf azcopy.tar.gz --strip-components=1
execHandle "Installing azcopy" mv azcopy /home/cloudcontrol/bin
execHandle "Making azcopy executable" chmod +x /home/cloudcontrol/bin/azcopy

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"

