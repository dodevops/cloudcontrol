if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ]
then
  echo "Installing jq..."
  if ! OUTPUT=$(sudo apk add jq)
  then
    echo -e "Can't install jq:\n${OUTPUT}"
    exit 1
  fi
elif [ "X$(cat /home/cloudcontrol/flavour)X" == "XawsX" ]
then
  echo "Installing jq..."
  if ! OUTPUT=$(sudo yum install -y jq)
  then
    echo -e "Can't install jq:\n${OUTPUT}"
    exit 1
  fi
fi
