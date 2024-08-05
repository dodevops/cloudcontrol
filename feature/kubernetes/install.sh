. /feature-installer-utils.sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

case "${FLAVOUR}" in
  aws)
    . "${SCRIPT_DIR}/install-aws.sh"
    ;;
  azure)
    . "${SCRIPT_DIR}/install-azure.sh"
    ;;
  gcloud)
    . "${SCRIPT_DIR}/install-gcloud.sh"
    ;;
  simple)
    . "${SCRIPT_DIR}/install-simple.sh"
    ;;
  tanzu)
    . "${SCRIPT_DIR}/install-tanzu.sh"
    ;;

esac

installKubernetes

if [ -n "${KUBECTL_DEFAULT_CONTEXT}" ]; then
  execHandle "Switching to default context" kubectl config use-context "${KUBECTL_DEFAULT_CONTEXT}"
  echo kubectl config use-context "${KUBECTL_DEFAULT_CONTEXT}" >> ~/bin/k8s-relogin
fi
