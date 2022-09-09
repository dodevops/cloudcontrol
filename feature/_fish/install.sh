. /feature-installer-utils.sh

FLAVOUR="$(cat /home/cloudcontrol/flavour)"
if [ "X${FLAVOUR}X" == "XazureX" ] || [ "X${FLAVOUR}X" == "XsimpleX" ] || [ "X${FLAVOUR}X" == "XtanzuX" ]
then
  echo "Installing packages"
  execHandle 'Installing fish' sudo apk add fish perl fzf git
elif [ "X${FLAVOUR}X" == "XawsX" ]
then
  execHandle 'Downloading fish repo' sudo curl -f -s -L https://download.opensuse.org/repositories/shells:fish:release:3/CentOS_7/shells:fish:release:3.repo -o /etc/yum.repos.d/shells:fish:release:3.repo
  execHandle 'Installing fish' sudo yum install -y fish git

  TEMPDIR=$(mktemp -d)
  cd "${TEMPDIR}" || exit
  execHandle 'Downloading fzf' curl -f -s -L https://github.com/junegunn/fzf/archive/master.zip -o master.zip
  execHandle 'Unzipping fzf' unzip master.zip
  execHandle 'Moving fzf' mv fzf-master ~/bin
  execHandle 'Installing fzf' ~/bin/fzf-master/install --all
  cd - &>/dev/null || exit
  rm -rf "${TEMPDIR}"
fi

execHandle 'Installing fisher' curl -f https://git.io/fisher --create-dirs -sLo /home/cloudcontrol/.config/fish/functions/fisher.fish

execHandle 'Installing fish packages' fish -c "fisher install edc/bass evanlucas/fish-kubectl-completions FabioAntunes/fish-nvm jethrokuan/fzf matchai/spacefish jethrokuan/fzf"
mkdir -p /home/cloudcontrol/.config/fish/conf.d &>/dev/null
execHandle 'Installing spacefish configuration' cp /home/cloudcontrol/feature-installers/_fish/spacefish.fish /home/cloudcontrol/.config/fish/conf.d

echo "fish" > /home/cloudcontrol/.shell

cat <<EOF >> ~/.config/fish/conf.d/cloudcontrol.fish
if test -n "\$SSH_AUTH_SOCK" && test -e "\$SSH_AUTH_SOCK"
  sudo /bin/chmod 0777 \$SSH_AUTH_SOCK
end
EOF

if [ "X${FLAVOUR}X" == "XawsX" ]
then
  cat <<EOF >>~/.config/fish/conf.d/aws.fish
set -x ORIGINAL_AWS_ACCESS_KEY_ID $AWS_ACCESS_KEY_ID
set -x ORIGINAL_AWS_SECRET_ACCESS_KEY $AWS_SECRET_ACCESS_KEY
function createSession -S
  source ~/bin/createSession.fish \$argv
end
EOF
fi
