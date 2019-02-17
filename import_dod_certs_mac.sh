# Created by - https://gist.github.com/dcode

export CERT_URL='http://iasecontent.disa.mil/pki-pke/Certificates_PKCS7_v5.4_DoD.zip'

# Download & Extract DoD root certificates
cd ~/Downloads/
curl -LOJ ${CERT_URL}

unzip $(basename ${CERT_URL})

cd $(basename ${CERT_URL} .zip)

# Convert pem.p7b certs to straight pem and import
for item in *.pem.p7b; do
  TOPDIR=$(pwd)
  TMPDIR=$(mktemp -d /tmp/$(basename ${item} .p7b).XXXXXX) || exit 1
  PEMNAME=$(basename ${item} .p7b)
  openssl pkcs7 -print_certs -in ${item} -out "${TMPDIR}/${PEMNAME}"
  cd ${TMPDIR}
  split -p '^$' ${PEMNAME}
  rm $(ls x* | tail -1)
  for cert in x??; do
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ${cert}
  done
  
  cd ${TOPDIR}
  rm -rf ${TMPDIR}
done
