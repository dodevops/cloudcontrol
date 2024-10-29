. /feature-installer-utils.sh

if [[ "${FLAVOUR}" =~ (simple|tanzu|gcloud) ]]
then
  execHandle "Installing vim" sudo apk add vim
elif [[ "${FLAVOUR}" =~ (aws|azure) ]]
then
  execHandle "Installing vim" sudo yum install -y vim
fi
