. /feature-installer-utils.sh

FLAVOUR="X$(cat /home/cloudcontrol/flavour)X"
if [ "${FLAVOUR}" == "XazureX" ] || [ "${FLAVOUR}" == "XsimpleX" ] || [ "${FLAVOUR}" == "XtanzuX" ]
then
  execHandle "Installing required libraries" sudo apk add gcompat
fi

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit
execHandle "Downloading bitwarden client" curl -L -o bw.zip "https://vault.bitwarden.com/download/?app=cli&platform=linux"
execHandle "Unzipping bitwarden client" unzip bw.zip
execHandle "Making bitwarden client executable" chmod +x bw
execHandle "Installing bitwarden client" mv bw /home/cloudcontrol/bin
cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"
