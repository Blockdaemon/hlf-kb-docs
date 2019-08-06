#!/bin/bash
. config.env

make artifacts

mkdir -p PeerAdmin/msp/admincerts
cp -f PeerAdmin/msp/signcerts/* PeerAdmin/msp/admincerts

export FABRIC_CFG_PATH=$PWD
#export FABRIC_LOGGING_SPEC=DEBUG

export CORE_PEER_PROFILE_ENABLED=true
export CORE_PEER_LOCALMSPID=${NETWORK_ID}-peerOrg
export CORE_PEER_MSPCONFIGPATH=PeerAdmin/msp
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_ROOTCERT_FILE="${PWD}/tlsca-${NETWORK_ID}.pem"

echo "Creating $CHANNEL"
export CORE_PEER_ADDRESS="peer-${ANCHOR_PEERS[0]}.${NETWORK_ID}${ENV}.bdnodes.net:7051"
peer channel create -c mychannel -f ./artifacts/mychannel.txn --tls -o orderer.${NETWORK_ID}${ENV}.bdnodes.net:7050 --cafile=${CORE_PEER_TLS_ROOTCERT_FILE}
echo "Adding all ANCHOR_PEERS to $CHANNEL"
peer channel update -c mychannel -f ./artifacts/mychannel-anchor-peers.txn --tls -o orderer.${NETWORK_ID}${ENV}.bdnodes.net:7050 --cafile=${CORE_PEER_TLS_ROOTCERT_FILE}

for NODE_ID in "${ANCHOR_PEERS[@]}"; do
    export CORE_PEER_ADDRESS="peer-${NODE_ID}.${NETWORK_ID}${ENV}.bdnodes.net:7051"
    echo "Joining peer-${NODE_ID} to $CHANNEL"
    peer channel join -b ./mychannel.block
done
