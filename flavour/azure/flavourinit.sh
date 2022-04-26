#!/usr/bin/env bash
echo "Logging in..."

tenantArg=()

if [ "X${AZ_TENANTID}X" != "XX" ]
then
  tenantArg+=("--tenant" "${AZ_TENANTID}")
fi

if ! az login "${tenantArg[@]}"
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

echo "Preparing bashrc"
cat <<EOF >>~/.bashrc
if [ -n "\${SSH_AUTH_SOCK}" ] && [ -e "\${SSH_AUTH_SOCK}" ]
then
  sudo /bin/chmod 0777 \${SSH_AUTH_SOCK}
fi
EOF
