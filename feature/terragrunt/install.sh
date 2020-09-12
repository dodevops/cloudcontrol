echo "Downloading terragrunt..."
if ! curl -s -L "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" -o /home/cloudcontrol/bin/terragrunt
then
  echo "Can not download terragrunt"
  exit 1
fi

echo "Installing terragrunt..."
if ! chmod +x /home/cloudcontrol/bin/terragrunt
then
  echo "Can not install terragrunt"
  exit 1
fi
