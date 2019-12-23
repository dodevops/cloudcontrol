if [ "X${TERRAGRUNT_VERSION}X" == "XX" ]
then
  echo -n "* Terragrunt version to use: "
  read -r TERRAGRUNT_VERSION
  echo
fi

curl -L "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" -o /home/cloudcontrol/bin/terragrunt
chmod +x /home/cloudcontrol/bin/terragrunt
