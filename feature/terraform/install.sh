. /feature-installer-utils.sh

if [ -z "${TERRAFORM_VERSION}" ]
then
  echo "The terraform feature requires a version set using TERRAFORM_VERSION. See https://releases.hashicorp.com/terraform for valid versions"
  exit 1
fi

TERRAFORM_VERSION=$(checkAndCleanVersion "${TERRAFORM_VERSION}")

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

execHandle "Downloading terraform" curl -f -s -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_$(getPlatform).zip" --output terraform.zip
execHandle "Unpacking terraform"  unzip terraform.zip
execHandle "Installing terraform" mv terraform /home/cloudcontrol/bin/terraform

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"
