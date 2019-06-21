# Create and join a peer to a channel

***This documents the sequence of commands in `channel.sh`.***

## Prerequisites

* [Download and install the hyperledger fabric tools](Tools.md)
* [Create the initial PeerOrg admin](Bootstrap.md)

*In these examples, we will assume the new channel will be named `mychannel`*

## Generate a channel genesis block

*Consult the [README](README.md) for system requirements*

*We assume the PeerOrg admin has already been enrolled by following the [bootstrap](Bootstrap.md) instructions and the admin's MSP is in `PeerAdmin/msp`*

Create `config.env` from the example:

```shell
cp config.env-example config.env
```

Now edit `config.env`. Set `NETWORK_ID` to your `<NetworkID>`, and `ANCHOR_PEERS` to a quote enclosed, space separated list of at least two `<NodeID>`s.

*In these examples, `<NodeID>` is the ID of a peer node and `<NetworkID>` is the ID of the network as shown in the Network connect page. Omit the `<>`'s, e.g. `NETWORK_ID="abcdefgh"`.
`ANCHOR_PEERS` should have at leleast two nodes!*

#### Generate `configtx.yaml` using parameters from `config.env`

```shell
make configtx.yaml
```

### Gather public keys into a MSP for genesis block creation

```shell
mkdir -p mychannel/msp/cacerts/ mychannel/msp/admincerts/
cp -f PeerAdmin/msp/cacerts/*.pem mychannel/msp/cacerts/
cp -f PeerAdmin/msp/signcerts/cert.pem mychannel/msp/admincerts/
```

This adds the PeerAdmin to the new channel as an `ADMIN` by putting its public key into `msp/admincerts`

### Generate genesis block and anchor peer update

```shell
mkdir -p artifacts/
configtxgen -configPath $PWD -profile SingleMSPChannel -outputCreateChannelTx artifacts/mychannel.txn -channelID mychannel
configtxgen -configPath $PWD -profile SingleMSPChannel -outputAnchorPeersUpdate artifacts/mychannel-anchor-peers.txn -channelID mychannel -asOrg PeerOrg
```

## Create/update/join channel

### Make the PeerAdmin an admin of the local peer instances we will be running
```shell
mkdir -p PeerAdmin/msp/admincerts
cp -f PeerAdmin/msp/signcerts/* PeerAdmin/msp/admincerts
```

### Set up environment

```shell
. config.env

export FABRIC_CFG_PATH=$PWD
export CORE_PEER_MSPCONFIGPATH="PeerAdmin/msp"
export CORE_PEER_LOCALMSPID="${NETWORK_ID}-peerOrg"
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_ROOTCERT_FILE="${PWD}/tlsca-${NETWORK_ID}.pem"
```

### Create/update channel

*Note that `peer channel create/update` only has to be done **once** (in this example, for the first `<NodeID>` in `ANCHOR_PEERS`), but `peer join` has to be done for **each** `<NodeID>` in `ANCHOR_PEERS` we specified in `configtx.yaml` via `config.env`.*

```shell
export CORE_PEER_ADDRESS="peer-${ANCHOR_PEERS[0]}.${NETWORK_ID}.bdnodes.net:7051"
peer channel create -c mychannel -f ./artifacts/mychannel.txn --tls -o orderer.${NETWORK_ID}.bdnodes.net:7050 --cafile=${CORE_PEER_TLS_ROOTCERT_FILE}
peer channel update -c mychannel -f ./artifacts/mychannel-anchor-peers.txn --tls -o orderer.${NETWORK_ID}.bdnodes.net:7050 --cafile=${CORE_PEER_TLS_ROOTCERT_FILE}
```

### Join anchor peers to channel

```shell
for NODE_ID in $ANCHOR_PEERS; do
    export CORE_PEER_ADDRESS="peer-${NODE_ID}.${NETWORK_ID}.bdnodes.net:7051"
    peer channel join -b ./mychannel.block
done
```
