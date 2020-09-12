TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

echo "Downloading velero..."

if ! curl -s -L "https://github.com/vmware-tanzu/velero/releases/download/${VELERO_VERSION}/velero-${VELERO_VERSION}-linux-amd64.tar.gz" --output velero.tar.gz
then
  echo "Can not download velero"
  exit 1
fi

echo "Unpacking velero..."

if ! tar xzf velero.tar.gz &>/dev/null
then
  echo "Can not unpack velero"
  exit 1
fi

echo "Installing velero..."

if ! mv "velero-${VELERO_VERSION}-linux-amd64/velero" /home/cloudcontrol/bin
then
  echo "Can not move velero binary"
  exit 1
fi

cd - || exit
rm -rf "${TEMPDIR}"
