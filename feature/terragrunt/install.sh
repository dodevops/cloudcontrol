. /feature-installer-utils.sh

TERRAGRUNT_VERSION=$(checkAndCleanVersion "${TERRAGRUNT_VERSION}")

execHandle "Downloading terragrunt" curl -f -s -L "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_$(getPlatform)" -o /home/cloudcontrol/bin/terragrunt
execHandle "Installing terragrunt" chmod +x /home/cloudcontrol/bin/terragrunt
