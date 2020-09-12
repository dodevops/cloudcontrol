TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

echo "Downloading terraform..."

if ! curl -s -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" --output terraform.zip
then
  echo "Can not download terraform"
  exit 1
fi

echo "Unpacking terraform..."

if ! unzip terraform.zip &>/dev/null
then
  echo "Can not unpack terraform"
  exit 1
fi

echo "Installing terraform..."

if ! mv terraform /home/cloudcontrol/bin/terraform
then
  echo "Can not move terraform binary"
fi

cd - || exit
rm -rf "${TEMPDIR}"
