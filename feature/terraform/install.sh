. /feature-installer-utils.sh

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

execHandle "Downloading terraform" curl -f -s -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_$(getPlatform).zip" --output terraform.zip
execHandle "Unpacking terraform"  unzip terraform.zip
execHandle "Installing terraform" mv terraform /home/cloudcontrol/bin/terraform

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"
