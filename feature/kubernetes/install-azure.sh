function installKubernetes() {
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
  # shellcheck disable=SC2088
  echo "~/bin/azure-relogin" >> ~/bin/k8s-relogin

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
}