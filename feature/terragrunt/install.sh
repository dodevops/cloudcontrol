. /feature-installer-utils.sh

execHandle "Downloading terragrunt" curl -f -s -L "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" -o /home/cloudcontrol/bin/terragrunt
execHandle "Installing terragrunt" chmod +x /home/cloudcontrol/bin/terragrunt
