. /feature-installer-utils.sh

FLAVOUR="X$(cat /home/cloudcontrol/flavour)X"
if [ "${FLAVOUR}" == "XazureX" ]; then
  IFS=' ' read -r -a install_options <<< "${AZ_K8S_INSTALL_OPTIONS:=""}"
  execHandle "Installing kubectl" sudo az aks install-cli "${install_options[@]}"

  if ${AZ_USE_ARM_SPI:-false}
  then
    if [ -e ~/.config/fish/conf.d/ ]
    then
      cat <<EOF >> ~/.config/fish/conf.d/kubernetes-spi.fish
export AAD_SERVICE_PRINCIPAL_CLIENT_ID=${ARM_CLIENT_ID}
export AAD_SERVICE_PRINCIPAL_CLIENT_SECRET=${ARM_CLIENT_SECRET}
EOF
    fi
    cat <<EOF >> ~/.bashrc
export AAD_SERVICE_PRINCIPAL_CLIENT_ID=${ARM_CLIENT_ID}
export AAD_SERVICE_PRINCIPAL_CLIENT_SECRET=${ARM_CLIENT_SECRET}
EOF
  fi

  echo "#!/bin/sh" > ~/bin/k8s-relogin

  AZ_DO_KUBELOGIN_CONVERT="${AZ_USE_ARM_SPI:-false}"
  for CLUSTER in $(echo "${AZ_K8S_CLUSTERS}" | tr "," "\n"); do
    K8S_RESOURCEGROUP=$(echo "$CLUSTER" | cut -d ":" -f 1)
    K8S_CLUSTER=$(echo "$CLUSTER" | cut -d ":" -f 2)
    K8S_SUBSCRIPTION=()

    if [[ "${K8S_RESOURCEGROUP}" == *"@"* ]]; then
      K8S_SUBSCRIPTION=(--subscription)
      K8S_SUBSCRIPTION+=("$(echo "${K8S_RESOURCEGROUP}" | cut -d "@" -f 2)")
      K8S_RESOURCEGROUP=$(echo "${K8S_RESOURCEGROUP}" | cut -d "@" -f 1)
    fi

    echo -n "Cluster ${K8S_CLUSTER} in resource group ${K8S_RESOURCEGROUP}"

    ADMIN_PARAMETER=""

    if [ "X${K8S_CLUSTER:0:1}X" == "X!X" ]; then
      ADMIN_PARAMETER="--admin"
      K8S_CLUSTER="${K8S_CLUSTER:1}"
      echo " as admin"
    else
      echo ""
    fi

    echo az aks get-credentials --overwrite-existing --resource-group "${K8S_RESOURCEGROUP}" --name "${K8S_CLUSTER}" ${ADMIN_PARAMETER} "${K8S_SUBSCRIPTION[@]}" >> ~/bin/k8s-relogin

    execHandle "Fetching k8s credentials for ${CLUSTER}" az aks get-credentials --resource-group "${K8S_RESOURCEGROUP}" --name "${K8S_CLUSTER}" ${ADMIN_PARAMETER} "${K8S_SUBSCRIPTION[@]}"

    # az aks get-credentials since kubernetes version 1.24 puts directly the kubelogin-way into kube config, hence the check here:
    if [ "$(az aks show -n "${K8S_CLUSTER}" -g "${K8S_RESOURCEGROUP}" "${K8S_SUBSCRIPTION[@]}" | jq -r .currentKubernetesVersion | cut -d"." -f2)" -le 23 ]; then
      AZ_DO_KUBELOGIN_CONVERT=true
    fi

  done
  chmod +x ~/bin/k8s-relogin

  if ${AZ_DO_KUBELOGIN_CONVERT}; then
    args=()
    if ${AZ_USE_ARM_SPI:-false};
    then
      args+=("-l" "spn")
    fi

    execHandle "Converting credentials to kubelogin" kubelogin convert-kubeconfig "${args[@]}"
    echo kubelogin convert-kubeconfig "${args[@]}" >> ~/bin/k8s-relogin
  fi
elif [ "${FLAVOUR}" == "XawsX" ]
then
  waitForMfaCode
  for CLUSTER in $(echo "${AWS_K8S_CLUSTERS}" | tr "," "\n")
  do
    ARN_OPTION=()
    K8S_CLUSTER=""
    SUDO_OPTION=()
    if echo "$CLUSTER" | grep "|.*@" &>/dev/null
    then
      K8S_CLUSTER=$(echo "$CLUSTER" | cut -d "|" -f 1)
      ARN=$(echo "$CLUSTER" | cut -d "|" -f 2 | cut -d "@" -f 1)
      SUDO_ARN=$(echo "$CLUSTER" | cut -d "|" -f 2 | cut -d "@" -f 2)
      ARN_OPTION=(--role-arn "${ARN}")
      SUDO_OPTION=(awsudo "${SUDO_ARN}")
      echo "Cluster ${K8S_CLUSTER} with role ${ARN} as role ${SUDO_ARN}"
    elif echo "$CLUSTER" | grep "|" &>/dev/null
    then
      K8S_CLUSTER=$(echo "$CLUSTER" | cut -d "|" -f 1)
      ARN=$(echo "$CLUSTER" | cut -d "|" -f 2)
      ARN_OPTION=(--role-arn "${ARN}")
      echo "Cluster ${K8S_CLUSTER} with role ${ARN}"
    else
      K8S_CLUSTER="$CLUSTER"
      echo "Cluster ${K8S_CLUSTER}"
    fi
    execHandle "Fetching k8s credentials for ${CLUSTER}" "${SUDO_OPTION[@]}" aws eks update-kubeconfig --name "${K8S_CLUSTER}" --alias "${K8S_CLUSTER}" "${ARN_OPTION[@]}"
  done

  TEMPFILE=$(mktemp)
  GPGCHECK=1

  if [ -n "${AWS_SKIP_GPG}" ];
  then
    GPGCHECK=0
  fi

  cat <<EOF > "${TEMPFILE}"
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-$(uname -m)
enabled=1
gpgcheck=${GPGCHECK}
repo_gpgcheck=${GPGCHECK}
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

  execHandle "Configuring package repository for kubectl" sudo mv "${TEMPFILE}" /etc/yum.repos.d/kubernetes.repo

  KUBECTL_PACKAGE="kubectl"
  if [[ "X${KUBECTL_VERSION}X" != "XX" ]]
  then
    KUBECTL_VERSION=$(checkAndCleanVersion "${KUBECTL_VERSION}")
    KUBECTL_PACKAGE="${KUBECTL_PACKAGE}-${KUBECTL_VERSION}"
  fi

  execHandle "Installing kubectl..." sudo yum install -y "$KUBECTL_PACKAGE"
elif [ "${FLAVOUR}" == "XsimpleX" ]
then
  KUBECTL_VERSION=$(checkAndCleanVersion "${KUBECTL_VERSION}")
  TEMPDIR=$(mktemp -d)
  cd "${TEMPDIR}" || exit
  execHandle "Downloading kubectl" curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION:-$(curl -L -s https://dl.k8s.io/release/stable.txt)}/bin/linux/$(getPlatform)/kubectl"
  execHandle "Making kubectl executable" chmod +x kubectl
  execHandle "Moving kubectl to bin" mv kubectl /home/cloudcontrol/bin
  cd - &>/dev/null || exit
  rm -rf "${TEMPDIR}"
elif [ "${FLAVOUR}" == "XtanzuX" ]
then
  TEMPDIR=$(mktemp -d)
  cd "${TEMPDIR}" || exit
  execHandle "Downloading kubectl and kubectl vsphere plugin" curl -k -L -o kubectl.zip "https://${TANZU_HOST}${TANZU_VSPHERE_PLUGIN_PATH:-/wcp/plugin/linux-amd64/vsphere-plugin.zip}"
  execHandle "Extracting zip" unzip kubectl.zip
  execHandle "Moving kubectl to bin" mv bin/kubectl /home/cloudcontrol/bin
  execHandle "Moving kubectl-vsphere to bin" mv bin/kubectl-vsphere /home/cloudcontrol/bin
  cd - &>/dev/null || exit
  rm -rf "${TEMPDIR}"

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
elif [ "${FLAVOUR}" == "XgcloudX" ]
then
  KUBECTL_VERSION=$(checkAndCleanVersion "${KUBECTL_VERSION}")
  TEMPDIR=$(mktemp -d)
  cd "${TEMPDIR}" || exit
  execHandle "Downloading kubectl" curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION:-$(curl -L -s https://dl.k8s.io/release/stable.txt)}/bin/linux/$(getPlatform)/kubectl"
  execHandle "Making kubectl executable" chmod +x kubectl
  execHandle "Moving kubectl to bin" mv kubectl /home/cloudcontrol/bin
  cd - &>/dev/null || exit
  rm -rf "${TEMPDIR}"

  if [ "${K8S_USE_GCLOUD_AUTH:-true}" == "true" ]
  then
    execHandle "Installing gke-cloud-auth-plugin" sudo gcloud components install gke-gcloud-auth-plugin
    export USE_GKE_GCLOUD_AUTH_PLUGIN=True
  fi

  for ZONEDCLUSTER in $(echo "${GCLOUD_K8S_CLUSTERS}" | tr "," "\n")
  do
    ZONE=$(echo "${ZONEDCLUSTER}" | cut -d ":" -f 1)
    CLUSTER=$(echo "${ZONEDCLUSTER}" | cut -d ":" -f 2)
    execHandle "Authenticating against cluster ${CLUSTER} in zone ${ZONE}" gcloud container clusters get-credentials "${CLUSTER}" --zone "${ZONE}"
    echo gcloud container clusters get-credentials "${CLUSTER}" --zone "${ZONE}" >> ~/bin/k8s-relogin
    chmod +x ~/bin/k8s-relogin
  done
fi

if [ -n "${KUBECTL_DEFAULT_CONTEXT}" ]; then
  execHandle "Switching to default context" kubectl config use-context "${KUBECTL_DEFAULT_CONTEXT}"
  echo kubectl config use-context "${KUBECTL_DEFAULT_CONTEXT}" >> ~/bin/k8s-relogin
fi
