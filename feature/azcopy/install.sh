. /feature-installer-utils.sh

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit
ARCH_SUFFIX=""
if [ "X$(uname -m)X" == "Xaarch64X" ]
then
  ARCH_SUFFIX="-arm64"
fi

execHandle "Downloading azcopy" curl -f -s -L "https://aka.ms/downloadazcopy-v10-linux${ARCH_SUFFIX}" -o azcopy.tar.gz
execHandle "Extracting azcopy" tar xzf azcopy.tar.gz --strip-components=1
execHandle "Installing azcopy" mv azcopy /home/cloudcontrol/bin
execHandle "Making azcopy executable" chmod +x /home/cloudcontrol/bin/azcopy

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"

