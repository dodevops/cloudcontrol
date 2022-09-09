. /feature-installer-utils.sh

IFS=' ' read -r -a packages_array <<< "${PACKAGES}"

FLAVOUR="$(cat /home/cloudcontrol/flavour)"
if [ "X${FLAVOUR}X" == "XazureX" ] || [ "X${FLAVOUR}X" == "XsimpleX" ] || [ "X${FLAVOUR}X" == "XtanzuX" ]
then
  execHandle "Installing packages" sudo apk add "${packages_array[@]}"
elif [ "X${FLAVOUR}X" == "XawsX" ]
then
  execHandle "Installing packages" sudo yum install -y "${packages_array[@]}"
fi
