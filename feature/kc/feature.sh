echo "Installing kc..."
if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ]
then
  sudo apk add dialog
elif [ "X$(cat /home/cloudcontrol/flavour)X" == "XawsX" ]
then
  sudo yum install -y dialog
fi
cp /home/cloudcontrol/feature-installers/kc/kc.sh /home/cloudcontrol/bin/kc
chmod +x /home/cloudcontrol/bin/kc
