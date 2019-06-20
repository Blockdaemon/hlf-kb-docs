# Create and join a peer to a channel

## Prerequisites

* [Download and install the hyperledger fabric tools](Tools.md)
* [Create the initial PeerOrg admin](Bootstrap.md)

*In these examples, we will assume the new channel will be named `mychannel`*

## Generate a channel genesis block

### Gather public keys into a MSP for genesis block creation

This adds the PeerAdmin to the new channel as an `ADMIN` by putting its public key into `msp/admincerts`

*In these examples, we assume the PeerOrg admin has been enrolled and its MSP is in `PeerAdmin/msp`*

### Create `configtx.yaml`

*Consult the [README](README.md) for system requirements*

```shell
cp config.env-example config.env
```

Edit `config.env`. Set `NETWORK_ID` to your `<NetworkID>`, and `ANCHOR_PEERS` to a quote enclosed, space separated list of at least two `<NodeID>`s.

#### Make a `configtx.yaml` and copy it to your working directory:

```
make
```

### Generate genesis block and anchor peer update

```shell
mkdir -p mychannel/msp/cacerts/ mychannel/msp/admincerts/
cp -f PeerAdmin/msp/cacerts/*.pem mychannel/msp/cacerts/
cp -f PeerAdmin/msp/signcerts/cert.pem mychannel/msp/admincerts/
mkdir -p artifacts/
configtxgen -configPath $PWD -profile SingleMSPChannel -outputCreateChannelTx artifacts/mychannel.txn -channelID mychannel
configtxgen -configPath $PWD -profile SingleMSPChannel -outputAnchorPeersUpdate artifacts/mychannel-anchor-peers.txn -channelID mychannel -asOrg PeerOrg
```

## Create/update/join channel

*In these examples, `<NodeID>` is the ID of a peer node and `<NetworkID>` is the ID of the network as shown in the Network connect page. Omit the `<>`'s, e.g. `NETWORK_ID="abcdefgh"`. Fetch/join will have to be done for every `<NodeID>` peer you wish to join to a channel, as specified in the `config.env` `ANCHOR_PEERS` setting for the `configtx.yaml` created above. `ANCHOR_PEERS` should have at leleast two nodes!*

```shell
ANCHOR_PEERS="<NodeID> <NodeID> .."
NETWORK_ID="<NetworkID>"

export FABRIC_CFG_PATH=$PWD
export CORE_PEER_MSPCONFIGPATH="PeerAdmin/msp"
export CORE_PEER_LOCALMSPID="${NETWORK_ID}-peerOrg"
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_ROOTCERT_FILE="${PWD}/tlsca-${NETWORK_ID}.pem"

export CORE_PEER_ADDRESS="peer-${ANCHOR_PEERS[0]}.${NETWORK_ID}.bdnodes.net:7051"
peer channel create -c mychannel -f ./artifacts/mychannel.txn --tls -o orderer.${NETWORK_ID}.bdnodes.net:7050 --cafile=${CORE_PEER_TLS_ROOTCERT_FILE}
peer channel update -c mychannel -f ./artifacts/mychannel-anchor-peers.txn --tls -o orderer.${NETWORK_ID}.bdnodes.net:7050 --cafile=${CORE_PEER_TLS_ROOTCERT_FILE}

for NODE_ID in $ANCHOR_PEERS; do
    export CORE_PEER_ADDRESS="peer-${NODE_ID}.${NETWORK_ID}.bdnodes.net:7051"
    peer channel fetch newest -c mychannel
    peer channel join -b ./mychannel.block
done
```
