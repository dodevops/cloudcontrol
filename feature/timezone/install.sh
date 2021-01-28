. /feature-installer-utils.sh

if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ]
then
  execHandle "Installing tzdata package" sudo apk add tzdata
fi
