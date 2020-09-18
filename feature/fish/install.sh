if [ "X$(cat /home/cloudcontrol/flavour)X" == "XazureX" ]
then
  echo "Installing packages..."
  sudo apk add fish perl fzf &>/dev/null
elif [ "X$(cat /home/cloudcontrol/flavour)X" == "XawsX" ]
then
  echo "Installing Fish package"
  sudo curl -s -L https://download.opensuse.org/repositories/shells:fish:release:3/CentOS_8/shells:fish:release:3.repo -o /etc/yum.repos.d/shells:fish:release:3.repo
  sudo yum install -y fish git &>/dev/null

  echo "Downloading fzf"
  TEMPDIR=$(mktemp -d)
  cd "${TEMPDIR}" || exit
  curl -s -L https://github.com/junegunn/fzf/archive/master.zip -o master.zip
  unzip master.zip &>/dev/null
  mv fzf-master ~/bin
  echo "Installing fzf"
  ~/bin/fzf-master/install --all &>/dev/null
  cd - || exit
  rm -rf "${TEMPDIR}"
fi

echo "Installing fisher"
curl https://git.io/fisher --create-dirs -sLo /home/cloudcontrol/.config/fish/functions/fisher.fish &>/dev/null

echo "Installing spacefish and dependent packages"
fish -c "fisher add edc/bass evanlucas/fish-kubectl-completions FabioAntunes/fish-nvm jethrokuan/fzf matchai/spacefish jethrokuan/fzf" &>/dev/null
cp /home/cloudcontrol/feature-installers/fish/spacefish.fish /home/cloudcontrol/.config/fish/conf.d

echo "fish" > /home/cloudcontrol/.shell
