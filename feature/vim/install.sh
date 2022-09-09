. /feature-installer-utils.sh

FLAVOUR="$(cat /home/cloudcontrol/flavour)"
if [ "X${FLAVOUR}X" == "XazureX" ] || [ "X${FLAVOUR}X" == "XsimpleX" ] || [ "X${FLAVOUR}X" == "XtanzuX" ]
then
  execHandle "Installing vim" sudo apk add vim
elif [ "X${FLAVOUR}X" == "XawsX" ]
then
  execHandle "Installing vim" sudo yum install -y vim
fi
