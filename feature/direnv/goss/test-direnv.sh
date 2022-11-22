echo "Testing without Direnv"

if [ -n "${DOTENV_TEST}" ]
then
  echo "Env variable was set to ${DOTENV_TEST}"
  exit 1
fi

echo "Loading direnv"

export PATH=$PATH:/home/cloudcontrol/bin

eval "$(direnv hook bash)"

cd /goss-sup || exit 99
direnv allow .
cd /goss-sup || exit 99
# This is in context of the direnv exec command as we can not directly test direnv, because it would need
# an interactive shell with a command prompt
# shellcheck disable=SC2016
TEST=$(direnv exec . bash -c 'echo $DOTENV_TEST')

if [ -z "${TEST}" ]
then
  echo "Env variable was not set"
  exit 1
elif [ "X${TEST}X" != "XIS_SETX" ]
then
  echo "Env variable was set to ${DOTENV_TEST} instead of IS_SET"
  exit 1
fi

echo "Test succeeded"

exit 0
