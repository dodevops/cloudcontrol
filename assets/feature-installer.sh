echo "## Features"

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
