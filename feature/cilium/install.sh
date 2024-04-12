. /feature-installer-utils.sh

if [ -n "${CILIUM_CLI_VERSION}" ]
then
  CILIUM_CLI_VERSION=$(checkAndCleanVersion "${CILIUM_CLI_VERSION}")
  echo "Using cilium version ${CILIUM_CLI_VERSION}..."
else
  CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)
fi

CLI_ARCH=$(getPlatform)

sudo curl -sL --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum} && \
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum && \
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin && \
sudo rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
