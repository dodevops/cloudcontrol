if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ]
then
  sudo apk add vim
elif [ "X$(cat /home/cloudcontrol/flavour)X" == "XawsX" ]
then
  sudo yum install -y vim
fi
