. /feature-installer-utils.sh

FLAVOUR="X$(cat /home/cloudcontrol/flavour)X"
if [ "${FLAVOUR}" == "XazureX" ] || [ "${FLAVOUR}" == "XsimpleX" ] || [ "${FLAVOUR}" == "XtanzuX" ]
then
  execHandle "Installing tzdata package" sudo apk add tzdata
fi
