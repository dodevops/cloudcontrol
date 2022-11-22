. /feature-installer-utils.sh

IFS=' ' read -r -a packages_array <<< "${PACKAGES}"

FLAVOUR="X$(cat /home/cloudcontrol/flavour)X"
if [[ "X${FLAVOUR}X" =~ X(azure|simple|tanzu|gcloud)X ]]
then
  execHandle "Installing packages" sudo apk add "${packages_array[@]}"
elif [ "${FLAVOUR}" == "XawsX" ]
then
  execHandle "Installing packages" sudo yum install -y "${packages_array[@]}"
fi
