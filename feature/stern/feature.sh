# Installs stern

echo "Installing STERN"

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}" || exit

if ! curl -L "https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64" --output stern
then
  echo "Can not download Stern"
  exit 1
fi

if ! chmod +x stern
then
  echo "Can not make stern executable"
  exit 1
fi

if ! mv stern /home/cloudcontrol/bin
then
  echo "Can not move stern binary"
  exit 1
fi

cd - || exit
rm -rf "${TEMPDIR}"




