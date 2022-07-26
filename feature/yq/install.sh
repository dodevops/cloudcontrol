. /feature-installer-utils.sh

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit
execHandle 'Downloading yq binary' curl -f -s -L "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION:-4.5.0}/yq_linux_$(getPlatform)" -o yq
execHandle 'Making yq executable' chmod +x yq
execHandle 'Installing yq' mv yq ~/bin
cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"
