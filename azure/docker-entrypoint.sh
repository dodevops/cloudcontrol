#!/usr/bin/env bash

echo "# CLOUD CONTROL SETUP"

echo "## AZURE"
echo

echo "Logging in..."
if ! az login
then
  echo "Can not login into Azure"
  exit 1
fi

if [ "X${AZ_SUBSCRIPTION}X" == "XX" ]
then
  echo -n "* Subscription: "
  read -r AZ_SUBSCRIPTION
  echo
fi

echo "Setting subscription..."
if ! az account set --subscription "${AZ_SUBSCRIPTION}"
then
  echo "Can not set subscription"
  exit 1
fi

echo "## Kubernetes"

if [ "X${K8S_CLUSTERS}X" == "XX" ]
then
  echo "Please enter the list of clusters in the form of <resourcegroup>:<clustername>, separated by comma"
  echo -n "* Clusters: "
  read -r K8S_CLUSTERS
  echo
fi

echo "Fetching cluster credentials..."

for CLUSTER in $(echo "${K8S_CLUSTERS}" | tr "," "\n")
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
if ! az aks install-cli
then
  echo "Can not install kubectl"
fi

echo "## Terraform"

if [ ! -r /credentials.terraform ]
then
  echo "Can not read terraform credentials"
  exit 1
fi

if ! cd /terraform
then
  echo "Can't find terraform base directory"
  exit 1
fi

if [ "X${TERRAFORM_VERSION}X" == "XX" ]
then
  echo -n "* Terraform version to use: "
  read -r TERRAFORM_VERSION
  echo
fi

cd /root

if ! curl "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" --output terraform.zip
then
  echo "Can not download terraform"
  exit 1
fi

if ! unzip terraform.zip
then
  echo "Can not unpack terraform"
  exit 1
fi

if ! mv terraform /usr/local/bin/terraform
then
  echo "Can not move terraform binary"
fi

echo "## Helm"

if [ "X${HELM_VERSION}X" == "XX" ]
then
  echo -n "* Helm version to use: "
  read -r HELM_VERSION
  echo
fi

if ! curl "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" --output helm.tar.gz
then
  echo "Can not download helm"
  exit 1
fi

if ! tar xzf helm.tar.gz
then
  echo "Can not unpack helm"
  exit 1
fi

if ! mv linux-amd64/helm /usr/local/bin
then
  echo "Can not move helm binary"
  exit 1
fi

if [ -r /tiller ]
then
  if ! mv linux-amd64/tiller /usr/local/bin
  then
    echo "Can not move tiller binary"
    exit 1
  fi
fi

echo "# Shell"

if [ "X${USE_SHELL:-fish}X" == "XfishX" ]
then
  apk add fish
  curl https://git.io/fisher --create-dirs -sLo /root/.config/fish/functions/fisher.fish
  fish -c "fisher add edc/bass evanlucas/fish-kubectl-completions FabioAntunes/fish-nvm jethrokuan/fzf matchai/spacefish"
  mv /root/spacefish.fish /root/.config/fish/conf.d
  ln -s /usr/bin/fish /root/shell
else
  apk add bash
  ln -s /bin/bash /root/shell
fi

echo "# FINISHED"
echo
echo "To use CLOUD CONTROL, run run.sh from now on."
echo "Hit CTRL-C to exit now."

while true; do sleep 30; done;
