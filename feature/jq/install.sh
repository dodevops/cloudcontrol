. /feature-installer-utils.sh

FLAVOUR="$(cat /home/cloudcontrol/flavour)"
if [ "X${FLAVOUR}X" == "XazureX" ] || [ "X${FLAVOUR}X" == "XsimpleX" ] || [ "X${FLAVOUR}X" == "XtanzuX" ]
then
  execHandle "Installing jq" sudo apk add jq
elif [ "X${FLAVOUR}X" == "XawsX" ]
then
  execHandle "Installing jq" sudo yum install -y jq
fi
