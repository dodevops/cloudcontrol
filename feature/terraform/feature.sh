if ! cd /terraform
then
  echo "Can't find terraform base directory"
  exit 1
fi

if [ "X${TERRAFORM_VERSION}X" == "XX" ]
then
  echo -n "* Terraform version to use: "
  read -r TERRAFORM_VERSION
  echo
fi

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

if ! curl "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" --output terraform.zip
then
  echo "Can not download terraform"
  exit 1
fi

if ! unzip terraform.zip
then
  echo "Can not unpack terraform"
  exit 1
fi

if ! mv terraform /home/cloudcontrol/bin/terraform
then
  echo "Can not move terraform binary"
fi

cd - || exit
rm -rf "${TEMPDIR}"
