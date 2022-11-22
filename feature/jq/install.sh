. /feature-installer-utils.sh

FLAVOUR="X$(cat /home/cloudcontrol/flavour)X"
if [[ "X${FLAVOUR}X" =~ X(azure|simple|tanzu|gcloud)X ]]
then
  execHandle "Installing jq" sudo apk add jq
elif [ "${FLAVOUR}" == "XawsX" ]
then
  execHandle "Installing jq" sudo yum install -y jq
fi
