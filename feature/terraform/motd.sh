cd /terraform

echo "Switched to main terraform directory."
echo

if [ -r /credentials/terraform ]
then
  echo "Go to the configuration you need and run"
  echo "    terraform init -backend-config=/credentials.terraform"
  echo "to initialize the configuration."
  echo
  echo "Afterwards, run the terraform commands with the parameter -var-file set to /credentials.terraform. i.e.:"
  echo "    terraform plan -var-file=/credentials.terraform"
fi
