if [ "X$(cat /flavour)X" == "XazureX" ]
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
    if ! az aks get-credentials --resource-group "${K8S_RESOURCEGROUP}" --name "${K8S_CLUSTER}"
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
fi
