. /feature-installer-utils.sh

if [ -z "${VELERO_VERSION}" ]
then
  echo "The velero feature requires a version set using VELERO_VERSION. See https://github.com/vmware-tanzu/velero/releases for valid versions"
  exit 1
fi

VELERO_VERSION=$(checkAndCleanVersion "${VELERO_VERSION}")

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

execHandle "Downloading velero" curl -f -s -L "https://github.com/vmware-tanzu/velero/releases/download/v${VELERO_VERSION}/velero-v${VELERO_VERSION}-linux-$(getPlatform).tar.gz" --output velero.tar.gz
execHandle "Unpacking velero" tar xzf velero.tar.gz

execHandle "Installing velero" mv "velero-v${VELERO_VERSION}-linux-$(getPlatform)/velero" /home/cloudcontrol/bin

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"
