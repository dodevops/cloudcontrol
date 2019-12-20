# 🐟 [Fish Shell](https://fishshell.com/) with [Spacefish theme](https://spacefish.matchai.me/) or Bash
# Installs and configures the default shell
# * Environment SHELL_TYPE: Set the shell (defaults to fish, but can be bash as well)

echo "Installing FISH"

sudo apk add fish perl fzf
curl https://git.io/fisher --create-dirs -sLo /home/cloudcontrol/.config/fish/functions/fisher.fish
fish -c "fisher add edc/bass evanlucas/fish-kubectl-completions FabioAntunes/fish-nvm jethrokuan/fzf matchai/spacefish jethrokuan/fzf"
cp /home/cloudcontrol/feature-installers/fish/spacefish.fish /home/cloudcontrol/.config/fish/conf.d
echo "fish" > /home/cloudcontrol/.shell
