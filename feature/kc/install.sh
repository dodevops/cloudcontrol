. /feature-installer-utils.sh

FLAVOUR="X$(cat /home/cloudcontrol/flavour)X"
if [[ "X${FLAVOUR}X" =~ X(azure|simple|tanzu|gcloud)X ]]
then
  execHandle "Installing dialog package" sudo apk add dialog
elif [ "${FLAVOUR}" == "XawsX" ]
then
  execHandle "Installing dialog package" sudo yum install -y dialog
fi

execHandle "Installing kc" cp /home/cloudcontrol/feature-installers/kc/kc.sh /home/cloudcontrol/bin/kc
execHandle "Making kc executable" chmod +x /home/cloudcontrol/bin/kc
