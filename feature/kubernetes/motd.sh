echo "kubectl is installed and the following contexts are available:"

kubectl config get-contexts -o "name" | sed -e "s/^/* /gi"
