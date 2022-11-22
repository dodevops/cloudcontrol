. /feature-installer-utils.sh

FLAVOUR="X$(cat /home/cloudcontrol/flavour)X"
if [[ "X${FLAVOUR}X" =~ X(azure|simple|tanzu|gcloud)X ]]
then
  execHandle "Installing tzdata package" sudo apk add tzdata
fi
