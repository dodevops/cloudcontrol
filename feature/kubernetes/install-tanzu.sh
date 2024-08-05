function installKubernetes() {
  prepare
  execHandle "Downloading kubectl and kubectl vsphere plugin" curl -k -L -o kubectl.zip "https://${TANZU_HOST}${TANZU_VSPHERE_PLUGIN_PATH:-/wcp/plugin/linux-amd64/vsphere-plugin.zip}"
  execHandle "Extracting zip" unzip kubectl.zip
  execHandle "Moving kubectl to bin" mv bin/kubectl /home/cloudcontrol/bin
  execHandle "Moving kubectl-vsphere to bin" mv bin/kubectl-vsphere /home/cloudcontrol/bin
  cleanup

  echo "#!/bin/sh" > ~/bin/k8s-relogin

  PATH=$PATH:/home/cloudcontrol/bin

  loginArgs=("--server" "${TANZU_HOST}" "--vsphere-username" "${TANZU_USERNAME}")

  if [ "X${TANZU_SKIP_TLS_VERIFY:-no}X" == "XyesX" ]
  then
    loginArgs+=("--insecure-skip-tls-verify")
  fi

  if [ "X${TANZU_ADD_CONTROL_CLUSTER:-no}X" == "XyesX" ]
  then
    execHandle "Authenticating against control cluster" kubectl vsphere login "${loginArgs[@]}"
    echo kubectl vsphere login "${loginArgs[@]}" >> ~/bin/k8s-relogin
  fi

  for NAMESPACEDCLUSTER in $(echo "${TANZU_CLUSTERS}" | tr "," "\n")
  do
    NAMESPACE=$(echo "$NAMESPACEDCLUSTER" | cut -d ":" -f 1)
    CLUSTER=$(echo "$NAMESPACEDCLUSTER" | cut -d ":" -f 2)
    execHandle "Authenticating against cluster ${CLUSTER} in namespace ${NAMESPACE}" kubectl vsphere login "${loginArgs[@]}" --tanzu-kubernetes-cluster-namespace="${NAMESPACE}" --tanzu-kubernetes-cluster-name="${CLUSTER}"
    echo kubectl vsphere login "${loginArgs[@]}" --tanzu-kubernetes-cluster-namespace="${NAMESPACE}" --tanzu-kubernetes-cluster-name="${CLUSTER}" >> ~/bin/k8s-relogin
  done
  chmod +x ~/bin/k8s-relogin
}