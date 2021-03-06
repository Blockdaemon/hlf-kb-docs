#!/bin/bash
set -e

OS=$(uname -s)
if [ "$OS" == "Darwin" ]; then
    BASE64="base64 -D"
else
    BASE64="base64 -d"
fi

. config.env

curl -sSk https://ca-server.${NETWORK_ID}${ENV}.bdnodes.net:7054/api/v1/cainfo \
  | jq -r ".result.CAChain" | ${BASE64} > tlsca-${NETWORK_ID}.pem

export FABRIC_CA_CLIENT_TLS_CERTFILES="${PWD}/tlsca-${NETWORK_ID}.pem"
export FABRIC_CA_CLIENT_CANAME="ca-peer-org"

fabric-ca-client enroll \
  -u "https://${CA_USER}:${CA_PASS}@ca-server.${NETWORK_ID}${ENV}.bdnodes.net:7054"

fabric-ca-client register \
  -u "https://ca-server.${NETWORK_ID}${ENV}.bdnodes.net:7054" \
  --id.type=user \
  --id.name Admin@${NETWORK_ID}-peerOrg
