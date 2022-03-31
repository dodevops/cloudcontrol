. /feature-installer-utils.sh

if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ] || [ "X$(cat /home/cloudcontrol/flavour)X" == "XsimpleX" ] || [ "X$(cat /home/cloudcontrol/flavour)X" == "XtanzuX" ]
then
  execHandle "Installing tzdata package" sudo apk add tzdata
fi
