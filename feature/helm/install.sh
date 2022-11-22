. /feature-installer-utils.sh

HELM_VERSION=$(checkAndCleanVersion "${HELM_VERSION}")

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

execHandle "Downloading helm" curl -f -s "https://get.helm.sh/helm-v${HELM_VERSION}-linux-$(getPlatform).tar.gz" --output helm.tar.gz
execHandle "Unpacking helm" tar xzf helm.tar.gz
execHandle "Installing helm" mv "linux-$(getPlatform)/helm" /home/cloudcontrol/bin

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"
