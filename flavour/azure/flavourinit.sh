#!/usr/bin/env bash
echo "Logging in..."

tenantArg=()

if [ "X${AZ_TENANTID}X" != "XX" ]
then
  echo "Warning: This configuration uses the DEPRECATED AZ_TENANTID environment variable. Please use ARM_TENANT_ID instead. Support for this will be removed in the next major version after 10/2024."
  ARM_TENANT_ID=${AZ_TENANTID}
fi

if [ "X${ARM_TENANT_ID}X" != "XX" ]
then
  tenantArg+=("--tenant" "${AZ_TENANTID}")
fi

if ${AZ_USE_ARM_SPI:-false};
then
  tenantArg+=("--service-principal" "-u ${ARM_CLIENT_ID}" "-p ${ARM_CLIENT_SECRET}")
fi

if ! az login "${tenantArg[@]}"
then
  echo "Error: Can not login into Azure"
  exit 1
fi

echo "#!/bin/sh" > ~/bin/azure-relogin
cat <<EOF >>~/bin/azure-relogin
AZ_ACCOUNT_SHOW_OUTPUT="$(az account show 2>&1)"
if [ $? -eq 0 ]; then
  echo "Azure login still valid, no relogin required"
  exit 0
else
  echo "Azure login expired, relogin required, see following error:"
  echo "${AZ_ACCOUNT_SHOW_OUTPUT}"
  echo "Performing relogin now..."
fi
EOF
echo az login "${tenantArg[@]}" >> ~/bin/azure-relogin

if [ "X${AZ_SUBSCRIPTION}X" == "XX" ]
then
  echo "Warning: This configuration uses the DEPRECATED AZ_SUBSCRIPTION environment variable. Please use ARM_SUBSCRIPTION_ID instead. Support for this will be removed in the next major version after 10/2024."
  ARM_SUBSCRIPTION_ID=$AZ_SUBSCRIPTION
fi

if [ "X${ARM_SUBSCRIPTION_ID}X" == "XX" ]
then
  echo -n "Error: Please specify a subscription using the environment variable ARM_SUBSCRIPTION_ID"
  exit 1
fi

echo "Setting subscription..."
if ! az account set --subscription "${ARM_SUBSCRIPTION_ID}"
then
  echo "Error: Can not set subscription"
  exit 1
fi
echo az account set --subscription "${ARM_SUBSCRIPTION_ID}" >> ~/bin/azure-relogin

chmod +x ~/bin/azure-relogin

echo "Preparing bashrc"
cat <<EOF >>~/.bashrc
if [ -n "\${SSH_AUTH_SOCK}" ] && [ -e "\${SSH_AUTH_SOCK}" ]
then
  sudo /bin/chmod 0777 \${SSH_AUTH_SOCK}
fi
EOF
