. /feature-installer-utils.sh

if [[ "${FLAVOUR}" =~ (simple|tanzu|gcloud) ]]
then
  execHandle 'Installing fish' sudo apk add fish perl fzf git
elif [[ "${FLAVOUR}" == "azure" ]]
then
  prepare
  execHandle 'Installing fish' sudo yum install -y fish perl git
  execHandle 'Downloading fzf' curl -f -s -L https://github.com/junegunn/fzf/archive/master.zip -o master.zip
  execHandle 'Unzipping fzf' unzip master.zip
  execHandle 'Moving fzf' mv fzf-master ~/bin
  execHandle 'Installing fzf' ~/bin/fzf-master/install --all
  cleanup
elif [[ "${FLAVOUR}" == "aws" ]]
then
  prepare
  execHandle 'Downloading fish repo' sudo curl -f -s -L https://download.opensuse.org/repositories/shells:fish:release:3/CentOS_7/shells:fish:release:3.repo -o /etc/yum.repos.d/shells:fish:release:3.repo
  execHandle 'Installing fish' sudo yum install -y fish git
  execHandle 'Downloading fzf' curl -f -s -L https://github.com/junegunn/fzf/archive/master.zip -o master.zip
  execHandle 'Unzipping fzf' unzip master.zip
  execHandle 'Moving fzf' mv fzf-master ~/bin
  execHandle 'Installing fzf' ~/bin/fzf-master/install --all
  cleanup
fi

execHandle 'Installing fisher' fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'

execHandle 'Installing fish packages' fish -c "fisher install edc/bass evanlucas/fish-kubectl-completions FabioAntunes/fish-nvm jethrokuan/fzf matchai/spacefish jethrokuan/fzf"
mkdir -p /home/cloudcontrol/.config/fish/conf.d &>/dev/null
execHandle 'Installing spacefish configuration' cp /home/cloudcontrol/feature-installers/_fish/spacefish.fish /home/cloudcontrol/.config/fish/conf.d

echo "fish" > /home/cloudcontrol/.shell

cat <<EOF >> ~/.config/fish/conf.d/cloudcontrol.fish
if test -n "\$SSH_AUTH_SOCK" && test -e "\$SSH_AUTH_SOCK"
  sudo /bin/chmod 0777 \$SSH_AUTH_SOCK
end
EOF

if [ "${FLAVOUR}" == "XawsX" ]
then
  cat <<EOF >>~/.config/fish/conf.d/aws.fish
set -x ORIGINAL_AWS_ACCESS_KEY_ID $AWS_ACCESS_KEY_ID
set -x ORIGINAL_AWS_SECRET_ACCESS_KEY $AWS_SECRET_ACCESS_KEY
function createSession -S
  source ~/bin/createSession.fish \$argv
end
EOF
fi
