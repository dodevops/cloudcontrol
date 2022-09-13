. /feature-installer-utils.sh

FLAVOUR="X$(cat /home/cloudcontrol/flavour)X"
if [ "${FLAVOUR}" == "XazureX" ] || [ "${FLAVOUR}" == "XsimpleX" ] || [ "${FLAVOUR}" == "XtanzuX" ]
then
  execHandle "Installing jq" sudo apk add jq
elif [ "${FLAVOUR}" == "XawsX" ]
then
  execHandle "Installing jq" sudo yum install -y jq
fi
