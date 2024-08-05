function installKubernetes() {
  KUBECTL_VERSION=$(checkAndCleanVersion "${KUBECTL_VERSION}")
  prepare
  execHandle "Downloading kubectl" curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION:-$(curl -L -s https://dl.k8s.io/release/stable.txt)}/bin/linux/$(getPlatform)/kubectl"
  execHandle "Making kubectl executable" chmod +x kubectl
  execHandle "Moving kubectl to bin" mv kubectl /home/cloudcontrol/bin
  cleanup
}