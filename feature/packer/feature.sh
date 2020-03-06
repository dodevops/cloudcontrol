# 📦 [Packer](https://packer.io/)
# Installs packer

echo "Installing PACKER"

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

if ! curl "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" --output packer.zip
then
  echo "Can not download Packer"
  exit 1
fi

if ! unzip packer.zip
then
  echo "Can not unpack packer"
  exit 1
fi

if ! mv packer /home/cloudcontrol/bin
then
  echo "Can not move Packer binary"
  exit 1
fi

cd - || exit
rm -rf "${TEMPDIR}"
