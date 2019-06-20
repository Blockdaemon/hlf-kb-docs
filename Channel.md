# Create and join a peer to a channel

## Prerequisites

* [Download and install the hyperledger fabric tools](Tools.md)
* [Create the initial PeerOrg admin](Bootstrap.md)

*In these examples, we will assume the new channel will be named `MyChannel`*

## Generate a channel genesis block

### Gather public keys into a MSP for genesis block creation

This adds the PeerAdmin to the new channel as an `ADMIN` by putting its public key into `msp/admincerts`

*In these examples, we assume the PeerOrg admin has been enrolled and its MSP is in `PeerAdmin/msp`*

```shell
mkdir -p MyChannel/msp/cacerts/ MyChannel/msp/admincerts/
cp -f PeerAdmin/msp/cacerts/*.pem MyChannel/msp/cacerts/
cp -f PeerAdmin/msp/signcerts/cert.pem MyChannel/msp/admincerts/
```

### Create `configtx.yaml`

*Consult the [README](README.md) for system requirements*

```shell
git clone https://github.com/Blockdaemon/hlf-kb-docs
cd hlf-kb-docs
cp config.env-example config.env
```

Edit `config.env`. Set `NETWORK_ID` to your `<NetworkID>`, and `ANCHOR_PEERS` to a quote enclosed, space separated list of at least two `<NodeID>`s.

#### Make a `configtx.yaml` and copy it to your working directory:

```
make
cd ..
cp hlf-kb-docs/configtx.yaml .
```

### Generate genesis block and anchor peer update

```shell
mkdir -p artifacts/
configtxgen -configPath $PWD -profile SingleMSPChannel -outputCreateChannelTx artifacts/MyChannel.txn -channelID MyChannel
configtxgen -configPath $PWD -profile SingleMSPChannel -outputAnchorPeersUpdate artifacts/MyChannel-anchor-peers.txn -channelID MyChannel -asOrg PeerOrg
```

## Create/update/join channel

*In these examples, `<NodeID>` is the ID of the peer node and `<NetworkID>` is the ID of the network as shown in the Network connect page. Omit the `<>`'s, e.g. `NETWORK_ID="abcdefgh"`. It will have to be done for every `<NodeID>` peer you wish to join to a channel, as specified in the `config.env` `ANCHOR_PEERS` setting for the `configtx.yaml` created above.*

```shell
NODE_ID="<NodeID>"
NETWORK_ID="<NetworkID>"

export CORE_PEER_MSPCONFIGPATH="PeerAdmin/msp"
export CORE_PEER_LOCALMSPID="${NETWORK_ID}-peerOrg"
export CORE_PEER_ADDRESS="peer-${NODE_ID}.${NETWORK_ID}.bdnodes.net:7051"
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_ROOTCERT_FILE="${PWD}/tlsca-${NETWORK_ID}.pem"

touch core.yaml
peer channel create -c MyChannel -f ./artifacts/MyChannel.txn -o orderer.${NETWORK_ID}.bdnodes.net:7050
peer channel update -c MyChannel -f ./artifacts/MyChannel-anchor-peers.txn -o orderer.${NETWORK_ID}.bdnodes.net:7050
peer channel fetch newest -c MyChannel
peer channel join -b ./MyChannel.block
```

If you are familiar with bash you can also wrap the above with:
```shell
ANCHOR_PEERS="<NodeID> <NodeID> ..."
for NODE_ID in $ANCHOR_PEERS; do
...
done
````
