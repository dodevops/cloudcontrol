if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ]
then
  echo "Installing tzdata package..."
  sudo apk add tzdata &>/dev/null
fi
