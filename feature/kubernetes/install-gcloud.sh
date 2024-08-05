function installKubernetes() {
  KUBECTL_VERSION=$(checkAndCleanVersion "${KUBECTL_VERSION}")
  prepare
  execHandle "Downloading kubectl" curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION:-$(curl -L -s https://dl.k8s.io/release/stable.txt)}/bin/linux/$(getPlatform)/kubectl"
  execHandle "Making kubectl executable" chmod +x kubectl
  execHandle "Moving kubectl to bin" mv kubectl /home/cloudcontrol/bin
  cleanup

  if [ "${K8S_USE_GCLOUD_AUTH:-true}" == "true" ]
  then
    execHandle "Installing gke-cloud-auth-plugin" sudo gcloud components install gke-gcloud-auth-plugin
    export USE_GKE_GCLOUD_AUTH_PLUGIN=True
  fi

  for ZONEDCLUSTER in $(echo "${GCLOUD_K8S_CLUSTERS}" | tr "," "\n")
  do
    ZONE=$(echo "${ZONEDCLUSTER}" | cut -d ":" -f 1)
    CLUSTER=$(echo "${ZONEDCLUSTER}" | cut -d ":" -f 2)
    if [[ $ZONE =~ @ ]]
    then
      PROJECT=$(echo "$ZONE" | cut -d "@" -f 2)
      ZONE=$(echo "$ZONE" | cut -d "@" -f 1)
    fi
    command=(gcloud container clusters get-credentials "${CLUSTER}" --zone "${ZONE}")

    if [[ -n $PROJECT ]]
    then
      command+=(--project "${PROJECT}")
    fi
    execHandle "Authenticating against cluster ${CLUSTER} in zone ${ZONE}" "${command[@]}"
    echo "${command[@]}" >> ~/bin/k8s-relogin
    chmod +x ~/bin/k8s-relogin
  done
}