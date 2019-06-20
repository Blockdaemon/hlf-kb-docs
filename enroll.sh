#!/bin/bash
set -e
. config.env

export FABRIC_CA_CLIENT_TLS_CERTFILES="${PWD}/tlsca-${NETWORK_ID}.pem"
export FABRIC_CA_CLIENT_CANAME="ca-peer-org"

mkdir -p PeerAdmin

fabric-ca-client enroll \
  -u "https://Admin@${NETWORK_ID}-peerOrg:${PASSWORD}@ca-server.${NETWORK_ID}${ENV}.bdnodes.net:7054" \
  -H PeerAdmin --csr.names="O=${NETWORK_ID}-peerOrg"
