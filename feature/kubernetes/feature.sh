if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ]
then
  if [ "X${AZ_K8S_CLUSTERS}X" == "XX" ]
  then
    echo "Please enter the list of clusters in the form of <resourcegroup>:<clustername>, separated by comma"
    echo -n "* Clusters: "
    read -r AZ_K8S_CLUSTERS
    echo
  fi

  echo "Fetching cluster credentials..."

  for CLUSTER in $(echo "${AZ_K8S_CLUSTERS}" | tr "," "\n")
  do
    K8S_RESOURCEGROUP=$(echo "$CLUSTER" | cut -d ":" -f 1)
    K8S_CLUSTER=$(echo "$CLUSTER" | cut -d ":" -f 2)

    ADMIN_PARAMETER=""

    if [ "X${K8S_CLUSTER:0:1}X" == "X!X" ]
    then
      ADMIN_PARAMETER="--admin"
      K8S_CLUSTER="${K8S_CLUSTER:1}"
    fi

    if ! az aks get-credentials --resource-group "${K8S_RESOURCEGROUP}" --name "${K8S_CLUSTER}" ${ADMIN_PARAMETER}
    then
      echo "Can not fetch k8s credentials for ${CLUSTER}"
      exit 1
    fi
  done

  echo "Installing kubectl..."
  if ! sudo az aks install-cli
  then
    echo "Can not install kubectl"
  fi
elif [ "X$(cat /home/cloudcontrol/flavour)X" == "XawsX" ]; then
  if [ "X${AWS_K8S_CLUSTERS}X" == "XX" ]
  then
    echo "Please enter the list of clusters in the form of <clustername>[|<role-arn>], separated by comma"
    echo -n "* Clusters: "
    read -r AWS_K8S_CLUSTERS
    echo
  fi

  echo "Fetching cluster credentials..."

  for CLUSTER in $(echo "${AWS_K8S_CLUSTERS}" | tr "," "\n")
  do
    if echo "$CLUSTER" | grep "|"
    then
      K8S_CLUSTER=$(echo "$CLUSTER" | cut -d "|" -f 1)
      ARN=$(echo "$CLUSTER" | cut -d "|" -f 2)
      ARN_OPTION="--role-arn ${ARN}"
    else
      K8S_CLUSTER="$CLUSTER"
      ARN_OPTION=""
    fi
    if ! aws eks update-kubeconfig --name "${K8S_CLUSTER}" ${ARN_OPTION}
    then
      echo "Can not fetch k8s credentials for ${CLUSTER}"
      exit 1
    fi
  done

  echo "Installing kubectl..."

  cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

  if ! sudo yum install -y kubectl
  then
    echo "Can not install kubectl"
  fi
fi
