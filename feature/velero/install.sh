. /feature-installer-utils.sh

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

execHandle "Downloading velero" curl -f -s -L "https://github.com/vmware-tanzu/velero/releases/download/${VELERO_VERSION}/velero-${VELERO_VERSION}-linux-amd64.tar.gz" --output velero.tar.gz
execHandle "Unpacking velero" tar xzf velero.tar.gz &>/dev/null

execHandle "Installing velero" mv "velero-${VELERO_VERSION}-linux-amd64/velero" /home/cloudcontrol/bin

cd - || exit
rm -rf "${TEMPDIR}"
