if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ]
then
  echo "Installing packages..."
  execHandle 'Installing fish' sudo apk add fish perl fzf
elif [ "X$(cat /home/cloudcontrol/flavour)X" == "XawsX" ]
then
  echo "Installing Fish package"
  execHandle 'Downloading fish repo' sudo curl -s -L https://download.opensuse.org/repositories/shells:fish:release:3/CentOS_8/shells:fish:release:3.repo -o /etc/yum.repos.d/shells:fish:release:3.repo
  execHandle 'Installing fish' sudo yum install -y fish git

  echo "Downloading fzf"
  TEMPDIR=$(mktemp -d)
  cd "${TEMPDIR}" || exit
  execHandle 'Downloading fzf' curl -s -L https://github.com/junegunn/fzf/archive/master.zip -o master.zip
  execHandle 'Unzipping fzf' unzip master.zip
  execHandle 'Moving fzf' mv fzf-master ~/bin
  echo "Installing fzf"
  execHandle 'Installing fzf' ~/bin/fzf-master/install --all
  cd - || exit
  rm -rf "${TEMPDIR}"
fi

echo "Installing fisher"
execHandle 'Installing fisher' curl https://git.io/fisher --create-dirs -sLo /home/cloudcontrol/.config/fish/functions/fisher.fish

echo "Installing spacefish and dependent packages"
execHandle 'Installing fish packages' fish -c "fisher add edc/bass evanlucas/fish-kubectl-completions FabioAntunes/fish-nvm jethrokuan/fzf matchai/spacefish jethrokuan/fzf"
mkdir -p /home/cloudcontrol/.config/fish/conf.d &>/dev/null
execHandle 'Installing spacefish configuration' cp /home/cloudcontrol/feature-installers/fish/spacefish.fish /home/cloudcontrol/.config/fish/conf.d

echo "fish" > /home/cloudcontrol/.shell
