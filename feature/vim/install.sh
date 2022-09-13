. /feature-installer-utils.sh

FLAVOUR="X$(cat /home/cloudcontrol/flavour)X"
if [ "${FLAVOUR}" == "XazureX" ] || [ "${FLAVOUR}" == "XsimpleX" ] || [ "${FLAVOUR}" == "XtanzuX" ]
then
  execHandle "Installing vim" sudo apk add vim
elif [ "${FLAVOUR}" == "XawsX" ]
then
  execHandle "Installing vim" sudo yum install -y vim
fi
