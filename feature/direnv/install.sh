. /feature-installer-utils.sh

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

export PATH=$PATH:/home/cloudcontrol/bin

execHandle "Downloading installer" curl -sfL https://direnv.net/install.sh -o install.sh
execHandle "Installing direnv" bash install.sh

if [ -n "${USE_fish}" ]
then
  echo "Setting up direnv for fish"
  echo 'direnv hook fish | source' >> /home/cloudcontrol/.config/fish/config.fish
else
  echo "Setting up direnv for bash"
  # shellcheck disable=SC2016
  echo 'eval "$(direnv hook bash)"' >> /home/cloudcontrol/.bashrc
fi

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"
