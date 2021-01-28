. /feature-installer-utils.sh

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

execHandle "Downloading kubectl node-shell" curl -s -f -LO https://github.com/kvaps/kubectl-node-shell/raw/master/kubectl-node_shell
execHandle "Making kubectl node-shell executable" chmod +x ./kubectl-node_shell
execHandle "Installing kubectl node-shell" mv ./kubectl-node_shell /home/cloudcontrol/bin/kubectl-node_shell

cd - &>/dev/null || exit
rm -rf "${TEMPDIR}"
