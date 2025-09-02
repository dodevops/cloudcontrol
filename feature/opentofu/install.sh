. /feature-installer-utils.sh

if [ -z "${OPENTOFU_VERSION}" ]
then
  echo "The opentofu feature requires a version set using OPENTOFU_VERSION. See https://github.com/opentofu/opentofu/releases for valid versions"
  exit 1
fi

OPENTOFU_VERSION=$(checkAndCleanVersion "${OPENTOFU_VERSION}")

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

execHandle "Downloading opentofu" curl -f -s -L "https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_linux_$(getPlatform).zip" --output opentofu.zip
execHandle "Unpacking opentofu"  unzip opentofu.zip
execHandle "Installing opentofu" mv tofu /home/cloudcontrol/bin/tofu

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"
