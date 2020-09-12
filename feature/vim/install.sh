echo "Installing packages..."

if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ]
then
  sudo apk add vim &>/dev/null
elif [ "X$(cat /home/cloudcontrol/flavour)X" == "XawsX" ]
then
  sudo yum install -y vim &>/dev/null
fi
