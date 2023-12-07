. /feature-installer-utils.sh

if [ -n "${KREW_VERSION}" ]
then
  KREW_VERSION=$(checkAndCleanVersion "${KREW_VERSION}")
else
  KREW_VERSION="latest"
fi

FLAVOUR="X$(cat /home/cloudcontrol/flavour)X"
if [[ "X${FLAVOUR}X" =~ X(azure|simple|tanzu|gcloud)X ]]
then
  execHandle 'Installing git' sudo apk add git
elif [ "${FLAVOUR}" == "XawsX" ]
then
  execHandle 'Installing git' sudo yum install -y git
fi

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
KREW="krew-linux_${ARCH}"
execHandle "Downloading krew" curl -f -s -L "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" --output "${KREW}.tar.gz"
execHandle "Unpacking krew" tar zxvf "${KREW}.tar.gz" &>/dev/null
execHandle "Installing krew" "./${KREW}" install krew

if [ -n "${KREW_PLUGINS}" ]
then
  IFS=',' read -r -a krew_plugins_array <<< "${KREW_PLUGINS:=""}"
  for plugin in "${krew_plugins_array[@]}"
  do
    execHandle "Installing kubectl plugin $plugin" "./${KREW}" install "${plugin}"
  done
fi

if [[ $(cat /home/cloudcontrol/.shell) == "fish" ]]
then
  cat <<EOF >> ~/.config/fish/conf.d/krew.fish
  set -gx PATH $PATH $HOME/.krew/bin
EOF
else
  cat <<EOF >> /home/cloudcontrol/.bashrc
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
EOF
fi

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"
