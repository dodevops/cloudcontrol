# 🐟 [Fish Shell](https://fishshell.com/) with [Spacefish theme](https://spacefish.matchai.me/) or Bash
# Installs and configures the default shell
# * Environment SHELL_TYPE: Set the shell (defaults to fish, but can be bash as well)

echo "Installing FISH"

if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ]
then
  sudo apk add fish perl fzf
elif [ "X$(cat /home/cloudcontrol/flavour)X" == "XawsX" ]
then
  curl -L https://download.opensuse.org/repositories/shells:fish:release:3/CentOS_8/shells:fish:release:3.repo | sudo tee /etc/yum.repos.d/shells:fish:release:3.repo
  sudo yum install -y fish git

  TEMPDIR=$(mktemp -d)
  cd "${TEMPDIR}" || exit
  curl -L https://github.com/junegunn/fzf/archive/master.zip -o master.zip
  unzip master.zip
  fzf-master/install --all
  cd - || exit
  rm -rf "${TEMPDIR}"
fi

curl https://git.io/fisher --create-dirs -sLo /home/cloudcontrol/.config/fish/functions/fisher.fish
fish -c "fisher add edc/bass evanlucas/fish-kubectl-completions FabioAntunes/fish-nvm jethrokuan/fzf matchai/spacefish jethrokuan/fzf"
cp /home/cloudcontrol/feature-installers/fish/spacefish.fish /home/cloudcontrol/.config/fish/conf.d
echo "fish" > /home/cloudcontrol/.shell
