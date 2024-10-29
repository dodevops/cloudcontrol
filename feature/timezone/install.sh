. /feature-installer-utils.sh

if [[ "${FLAVOUR}" =~ (simple|tanzu|gcloud) ]]
then
  execHandle "Installing tzdata package" sudo apk add tzdata
elif [[ "${FLAVOUR}" =~ (azure) ]]
then
  execHandle "Installing tzdata package" sudo yum install -y tzdata
fi
