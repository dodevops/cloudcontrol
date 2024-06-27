. /feature-installer-utils.sh

# Prepare a workspace for installing the feature
prepare

download "https://github.com/cert-manager/cmctl/releases/${CMCTL_VERSION:-latest}/download/cmctl_linux_$(getPlatform)" cmctl
execHandle "Making cmctl executable" chmod +x cmctl
execHandle "Copying tool to ${BINPATH}" cp cmctl "${BINPATH}"
cleanup