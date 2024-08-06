. /feature-installer-utils.sh

if [ -n "${K9S_VERSION}" ]
then
  K9S_VERSION=$(checkAndCleanVersion "${K9S_VERSION}")
else
  K9S_VERSION="latest"
fi

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

downloadFromGithub derailed k9s "${K9S_VERSION}" k9s_Linux_ .tar.gz k9s.tar.gz

execHandle "Unpacking k9s" tar xzf k9s.tar.gz
execHandle "Installing k9s" mv k9s /home/cloudcontrol/bin
execHandle "Making k9s executable" chmod +x /home/cloudcontrol/bin/k9s

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"