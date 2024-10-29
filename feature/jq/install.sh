. /feature-installer-utils.sh

FLAVOUR="X$(cat /home/cloudcontrol/flavour)X"
if [[ "${FLAVOUR}" =~ (simple|tanzu|gcloud) ]]
then
  execHandle "Installing jq" sudo apk add jq
elif [[ "${FLAVOUR}" =~ (azure|aws) ]]
then
  execHandle "Installing jq" sudo yum install -y jq
fi
