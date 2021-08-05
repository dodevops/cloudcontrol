. /feature-installer-utils.sh

IFS=' ' read -r -a packages_array <<< "${PACKAGES}"

if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ]; then
  execHandle "Installing packages" sudo apk add "${packages_array[@]}"
elif [ "X$(cat /home/cloudcontrol/flavour)X" == "XawsX" ]
then
  execHandle "Installing packages" sudo yum install -y "${packages_array[@]}"
fi
