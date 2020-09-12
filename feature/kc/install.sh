echo "Installing dialog package..."

if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ]
then
  sudo apk add dialog &>/dev/null
elif [ "X$(cat /home/cloudcontrol/flavour)X" == "XawsX" ]
then
  sudo yum install -y dialog &>/dev/null
fi

echo "Installing kc..."

cp /home/cloudcontrol/feature-installers/kc/kc.sh /home/cloudcontrol/bin/kc
chmod +x /home/cloudcontrol/bin/kc
