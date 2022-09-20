. /feature-installer-utils.sh

FLAVOUR="X$(cat /home/cloudcontrol/flavour)X"
if [ "${FLAVOUR}" == "XazureX" ] || [ "${FLAVOUR}" == "XsimpleX" ] || [ "${FLAVOUR}" == "XtanzuX" ]
then
  execHandle "Copying certificates to the OS target location" sudo cp "${CERTIFICATES_PATH:=/certificates}"/*.pem /usr/local/share/ca-certificates/
  execHandle "Updating certificate bundle" sudo su - -c "cat /usr/local/share/ca-certificates/*.pem >> /etc/ssl/certs/ca-certificates.crt"
elif [ "${FLAVOUR}" == "XawsX" ]
then
  execHandle "Copying certificates to the OS target location" sudo cp "${CERTIFICATES_PATH:=/certificates}"/*.pem /etc/pki/ca-trust/source/anchors/
  execHandle "Updating certificate bundle" sudo /usr/bin/update-ca-trust
fi