echo "## Features"

echo "bash" > /home/cloudcontrol/.shell

function execHandle {
  TITLE=$1
  shift
  if ! OUTPUT=$("$@")
  then
    echo "Error ${TITLE}: $OUTPUT"
    exit 1
  fi

}}

for FEATUREDIR in /home/cloudcontrol/feature-installers/*
do
  FEATURE=$(basename "${FEATUREDIR}")
  USE_VARIABLE="USE_${FEATURE}"
  if [ "X${!USE_VARIABLE}X" == "XyesX" ]
  then
    echo "${FEATURE}" >> /home/cloudcontrol/features
    echo "### ${FEATURE}"
    source "${FEATUREDIR}/feature.sh"
  fi
done
