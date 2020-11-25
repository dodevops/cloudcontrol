if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ]; then
  echo "Fetching cluster credentials..."

  for CLUSTER in $(echo "${AZ_K8S_CLUSTERS}" | tr "," "\n"); do
    K8S_RESOURCEGROUP=$(echo "$CLUSTER" | cut -d ":" -f 1)
    K8S_CLUSTER=$(echo "$CLUSTER" | cut -d ":" -f 2)

    echo -n "Cluster ${K8S_CLUSTER} in resource group ${K8S_RESOURCEGROUP}"

    ADMIN_PARAMETER=""

    if [ "X${K8S_CLUSTER:0:1}X" == "X!X" ]; then
      ADMIN_PARAMETER="--admin"
      K8S_CLUSTER="${K8S_CLUSTER:1}"
      echo -n "as admin"
    fi

    echo

    if ! OUTPUT=$(az aks get-credentials --resource-group "${K8S_RESOURCEGROUP}" --name "${K8S_CLUSTER}" ${ADMIN_PARAMETER})
    then
      echo -e "Can not fetch k8s credentials for ${CLUSTER}:\n ${OUTPUT}"
      exit 1
    fi
  done

  echo "Installing kubectl..."

  if ! sudo az aks install-cli &>/dev/null
  then
    echo "Can not install kubectl"
  fi
elif [ "X$(cat /home/cloudcontrol/flavour)X" == "XawsX" ]
then
  echo "Fetching cluster credentials..."

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
      ARN_OPTION=(--role-arn ${ARN})
      SUDO_OPTION=(awsudo ${SUDO_ARN})
      echo "Cluster ${K8S_CLUSTER} with role ${ARN} as role ${SUDO_ARN}"
    elif echo "$CLUSTER" | grep "|" &>/dev/null
    then
      K8S_CLUSTER=$(echo "$CLUSTER" | cut -d "|" -f 1)
      ARN=$(echo "$CLUSTER" | cut -d "|" -f 2)
      ARN_OPTION=(--role-arn ${ARN})
      echo "Cluster ${K8S_CLUSTER} with role ${ARN}"
    else
      K8S_CLUSTER="$CLUSTER"
      echo "Cluster ${K8S_CLUSTER}"
    fi
    if ! OUTPUT=$("${SUDO_OPTION[@]}" aws eks update-kubeconfig --name "${K8S_CLUSTER}" --alias "${K8S_CLUSTER}" "${ARN_OPTION[@]}")
    then
      echo -e "Can not fetch k8s credentials for ${CLUSTER}:\n ${OUTPUT}"
      exit 1
    fi
  done

  cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo &>/dev/null
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

  echo "Installing kubectl..."

  if ! sudo yum install -y kubectl &>/dev/null
  then
    echo "Can not install kubectl"
  fi
fi
