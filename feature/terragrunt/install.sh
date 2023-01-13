. /feature-installer-utils.sh

if [ -z "${TERRAGRUNT_VERSION}" ]
then
  echo "The terragrunt feature requires a version set using TERRAGRUNT_VERSION. See https://github.com/gruntwork-io/terragrunt/releases for valid versions"
  exit 1
fi

TERRAGRUNT_VERSION=$(checkAndCleanVersion "${TERRAGRUNT_VERSION}")

execHandle "Downloading terragrunt" curl -f -s -L "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_$(getPlatform)" -o /home/cloudcontrol/bin/terragrunt
execHandle "Installing terragrunt" chmod +x /home/cloudcontrol/bin/terragrunt
