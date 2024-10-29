. /feature-installer-utils.sh

IFS=' ' read -r -a packages_array <<< "${PACKAGES}"

FLAVOUR="X$(cat /home/cloudcontrol/flavour)X"
if [[ "${FLAVOUR}" =~ (simple|tanzu|gcloud) ]]
then
  execHandle "Installing packages" sudo apk add "${packages_array[@]}"
elif [[ "${FLAVOUR}" =~ (aws|azure) ]]
then
  execHandle "Installing packages" sudo yum install -y "${packages_array[@]}"
fi
