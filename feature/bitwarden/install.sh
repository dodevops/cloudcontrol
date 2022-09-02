. /feature-installer-utils.sh

if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ] || [ "X$(cat /home/cloudcontrol/flavour)X" == "XsimpleX" ] || [ "X$(cat /home/cloudcontrol/flavour)X" == "XtanzuX" ]
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
