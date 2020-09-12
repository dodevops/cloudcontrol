TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

echo "Downloading helm..."

if ! curl -s "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" --output helm.tar.gz
then
  echo "Can not download helm"
  exit 1
fi

echo "Unpacking helm..."

if ! tar xzf helm.tar.gz &>/dev/null
then
  echo "Can not unpack helm"
  exit 1
fi

echo "Installing helm..."

if ! mv linux-amd64/helm /home/cloudcontrol/bin
then
  echo "Can not move helm binary"
  exit 1
fi

if [ -r /tiller ]
then
  echo "Installing tiller..."
  if ! mv linux-amd64/tiller /home/cloudcontrol/bin
  then
    echo "Can not move tiller binary"
    exit 1
  fi
fi

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"
