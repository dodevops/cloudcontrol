. /feature-installer-utils.sh

if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ] || [ "X$(cat /home/cloudcontrol/flavour)X" == "XsimpleX" ]
then
  execHandle "Installing vim" sudo apk add vim
elif [ "X$(cat /home/cloudcontrol/flavour)X" == "XawsX" ]
then
  execHandle "Installing vim" sudo yum install -y vim
fi
