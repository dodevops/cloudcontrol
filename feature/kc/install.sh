. /feature-installer-utils.sh

FLAVOUR="$(cat /home/cloudcontrol/flavour)"
if [ "X${FLAVOUR}X" == "XazureX" ] || [ "X${FLAVOUR}X" == "XsimpleX" ] || [ "X${FLAVOUR}X" == "XtanzuX" ]
then
  execHandle "Installing dialog package" sudo apk add dialog
elif [ "X${FLAVOUR}X" == "XawsX" ]
then
  execHandle "Installing dialog package" sudo yum install -y dialog
fi

execHandle "Installing kc" cp /home/cloudcontrol/feature-installers/kc/kc.sh /home/cloudcontrol/bin/kc
execHandle "Making kc executable" chmod +x /home/cloudcontrol/bin/kc
