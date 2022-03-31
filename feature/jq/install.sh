. /feature-installer-utils.sh

if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ] || [ "X$(cat /home/cloudcontrol/flavour)X" == "XsimpleX" ] || [ "X$(cat /home/cloudcontrol/flavour)X" == "XtanzuX" ]
then
  execHandle "Installing jq" sudo apk add jq
elif [ "X$(cat /home/cloudcontrol/flavour)X" == "XawsX" ]
then
  execHandle "Installing jq" sudo yum install -y jq
fi
