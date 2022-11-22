. /feature-installer-utils.sh

FLAVOUR="X$(cat /home/cloudcontrol/flavour)X"
if [[ "X${FLAVOUR}X" =~ X(azure|simple|tanzu|gcloud)X ]]
then
  execHandle "Installing vim" sudo apk add vim
elif [ "${FLAVOUR}" == "XawsX" ]
then
  execHandle "Installing vim" sudo yum install -y vim
fi
