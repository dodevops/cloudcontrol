. /feature-installer-utils.sh

if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ]
then
  execHandle "Installing dialog package" sudo apk add dialog &>/dev/null
elif [ "X$(cat /home/cloudcontrol/flavour)X" == "XawsX" ]
then
  execHandle "Installing dialog package" sudo yum install -y dialog &>/dev/null
fi

execHandle "Installing kc" cp /home/cloudcontrol/feature-installers/kc/kc.sh /home/cloudcontrol/bin/kc
execHandle "Making kc executable" chmod +x /home/cloudcontrol/bin/kc
