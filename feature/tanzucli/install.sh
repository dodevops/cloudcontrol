. /feature-installer-utils.sh

if [ -n "${TANZUCLI_VERSION}" ]
then
  prepare
  VERSION=$(checkAndCleanVersion "${TANZUCLI_VERSION}")
  SUFFIX=".tar.gz"
  if [ "$(getPlatform)" = "arm64" ]
  then
    SUFFIX="-unstable.tar.gz"
  fi
  downloadFromGithub vmware-tanzu tanzu-cli "v${VERSION}" tanzu-cli-linux- "${SUFFIX}" tanzu-cli-linux.tar.gz
  execHandle "Extracting tanzu cli" tar xzf tanzu-cli-linux.tar.gz
  execHandle "Installing tanzu cli" mv "${VERSION}"/tanzu-cli* "${BINPATH}/tanzu-cli"
  execHandle "Making tanzu cli executable" chmod +x "${BINPATH}/tanzu-cli"
  cleanup
else
  echo "The tanzucli feature requires a version set using TANZUCLI_VERSION. See https://github.com/vmware-tanzu/tanzu-cli/releases for valid versions"
  exit 1
fi
