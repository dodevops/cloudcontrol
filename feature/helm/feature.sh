if [ "X${HELM_VERSION}X" == "XX" ]
then
  echo -n "* Helm version to use: "
  read -r HELM_VERSION
  echo
fi

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

if ! curl "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" --output helm.tar.gz
then
  echo "Can not download helm"
  exit 1
fi

if ! tar xzf helm.tar.gz
then
  echo "Can not unpack helm"
  exit 1
fi

if ! mv linux-amd64/helm /home/cloudcontrol/bin
then
  echo "Can not move helm binary"
  exit 1
fi

if [ -r /tiller ]
then
  if ! mv linux-amd64/tiller /home/cloudcontrol/bin
  then
    echo "Can not move tiller binary"
    exit 1
  fi
fi

cd - || exit
rm -rf "${TEMPDIR}"
