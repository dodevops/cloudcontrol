# The installer script for your feature, which is called in the init phase of CloudControl

# Include the feature installer utils which include helpers for the installation of your feature
# See /assets/feature-installer-utils.sh

. /feature-installer-utils.sh

# Create a temporary directory to work in
prepare

if [ "X${FLAVOUR}X" == "XsimpleX" ]
then
  # Do specific things for the simple flavour
  download "https://example.com/my-tool-for-simple.tar.gz" tool.tar.gz
elif [[ "X${FLAVOR}X" =~ X(azure|gcloud)X ]]
then
  # Do specific things for other flavours
  download "https://example.com/my-tool-for-others.tar.gz" tool.tar.gz
fi

# Do other things
execHandle "Extracting tool" tar xzf tool.tar.gz
execHandle "Making tool executable" chmod +x tool
execHandle "Copying tool to ${BINPATH}" cp tool "${BINPATH}"

# Cleanup what we did
cleanup