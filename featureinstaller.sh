echo "## Features"

for FEATURE in /home/cloudcontrol/feature-installers/*
do
  USE_VARIABLE="USE_${FEATURE}"
  if [ "X${USE_VARIABLE}X" == "XyesX" ]
  then
    echo "${FEATURE}" >> /home/cloudcontrol/features
    echo "### ${FEATURE}"
    source "${FEATURE}/feature.sh"
  fi
done
