TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

echo "Downloading packer..."

if ! curl -s -L "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" --output packer.zip
then
  echo "Can not download Packer"
  exit 1
fi

echo "Unpacking packer..."

if ! unzip packer.zip &>/dev/null
then
  echo "Can not unpack packer"
  exit 1
fi

echo "Installing packer..."

if ! mv packer /home/cloudcontrol/bin
then
  echo "Can not move Packer binary"
  exit 1
fi

cd - || exit
rm -rf "${TEMPDIR}"
